#!/usr/bin/env ruby
puts 'loading rails...'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + '/../config/environment')

puts 'generating summaries...'
if Rails.env.development?
  Summary.destroy_all 
end
ActiveRecord::Base.logger.level = 3;
[Anime, Manga].each do |klass|
  normalization = Recommendations::Normalizations::ZScoreCentering.new;
  rates_fetcher = Recommendations::RatesFetcher.new(klass);
  summary = nil;

  Comment.
    includes(:user, commentable: :linked).
    where(is_summary: true).
    order(id: :desc).
    find_each do |comment|
      db_entry = comment.commentable.linked
      next if db_entry.class.base_class != klass

      user = comment.user
      tone = Types::Summary::Tone[:neutral]

      rates_fetcher.user_ids = user.id
      rates_fetcher.user_cache_key = user.cache_key_with_version
      rates = rates_fetcher.fetch(normalization)

      normalized_score = rates.dig(user.id, db_entry.id)

      if normalized_score
        if normalized_score >= 0.095
          tone = Types::Summary::Tone[:positive]
        elsif normalized_score <= 0.095
          tone = Types::Summary::Tone[:negative]
        end
      end

      is_written_before_release =
        if (db_entry.released? && !db_entry.released_on) || (db_entry.is_a?(Manga) && db_entry.discontinued?)
          false
        elsif db_entry.ongoing? || db_entry.anons? || (db_entry.is_a?(Manga) && db_entry.paused?)
          true
        elsif db_entry.released? && db_entry.released_on?
          comment.created_at >= db_entry.released_on
        else
          puts 'zzzzzz'
          binding.pry
        end

      summary = Summary.new(
        user: user,
        body: comment.body,
        anime: (db_entry if db_entry.anime?),
        manga: (db_entry if db_entry.manga? || db_entry.ranobe?),
        tone: tone,
        is_written_before_release: is_written_before_release
      )
      summary.instance_variable_set :@is_migration, true
      Summary.wo_antispam do
        summary.save!
        ap summary
      rescue ActiveRecord::RecordInvalid
        raise unless summary.errors[:user_id].present?
      end
    end;
end;
