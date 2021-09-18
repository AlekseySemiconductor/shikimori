class BadCritiquesCleaner
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  MINIMUM_VOTES = 35

  def perform
    bad_critiques.each do |critique|
      critique.reject! rejecter, "Рецензию оценили минимум #{MINIMUM_VOTES} человек, из которых более 80% оставили негативную оценку."
    end
  end

private

  def rejecter
    @rejecter ||= User.find User::MESSANGER_ID
  end

  def bad_critiques
    critiques.select { |critique| low_level? critique }
  end

  def critiques
    @critiques ||= Critique.where(moderation_state: 'pending').to_a
  end

  def votes
    @vites ||= Vote
      .where(voteable_type: Critique.name, voteable_id: critiques.map(&:id))
      .where.not(user_id: User.suspicious)
      .to_a
  end

  def low_level? critique
    votes_total = critique.cached_votes_up + critique.cached_votes_down

    votes_total >= MINIMUM_VOTES &&
      (critique.cached_votes_down / votes_total) >= 0.8
  end
end
