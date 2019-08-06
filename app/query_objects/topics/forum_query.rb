class Topics::ForumQuery # rubocop:disable ClassLength
  method_object %i[
    scope
    forum
    user
    is_censored_forbidden
  ]

  FORUMS_QUERY = 'forum_id in (:user_forums)'
  NEWS_QUERY = <<-SQL.squish
    (
      type = '#{Topics::NewsTopic.name}' and
      generated = false
    ) or (
      type in (
        '#{Topics::EntryTopics::CosplayGalleryTopic.name}',
        '#{Topics::NewsTopics::ContestStatusTopic.name}'
      ) and
      generated = true
    )
  SQL

  CLUBS_JOIN = <<-SQL.squish
    left join clubs as clubs_1 on
      clubs_1.id = linked_id and linked_type = '#{Club.name}'

    left join club_pages on
      club_pages.id = linked_id and linked_type = '#{ClubPage.name}'

    left join clubs as clubs_2 on
      club_pages.club_id = clubs_2.id
  SQL
  CLUBS_WHERE = <<-SQL.squish
    (linked_type = '#{Club.name}' and linked_id in (:user_club_ids)) or
    (linked_type = '#{ClubPage.name}' and linked_id in (:user_club_page_ids)) or
      clubs_1.is_censored = false or
      clubs_2.is_censored = false
  SQL

  MY_CLUBS_QUERY = <<-SQL.squish
    (
      type in (
        #{ApplicationRecord.sanitize Topics::EntryTopics::ClubTopic.name},
        #{ApplicationRecord.sanitize Topics::ClubUserTopic.name}
      ) and #{Topic.table_name}.linked_id in (:user_club_ids)
    ) or
    (
      type =
        #{ApplicationRecord.sanitize Topics::EntryTopics::ClubPageTopic.name}
        and #{Topic.table_name}.linked_id in (:user_club_page_ids)
    )
  SQL

  def call # rubocop:disable all
    case @forum&.permalink
      when nil
        if @user
          user_forums
        else
          guest_forums
        end

      when 'reviews'
        reviews_forums

      when 'clubs'
        clubs_forums

      when 'news'
        news_forums

      when Forum::UPDATES_FORUM.permalink
        updates_forums

      when Forum::MY_CLUBS_FORUM.permalink
        my_clubs_forums

      else
        @scope
          .where(forum_id: @forum.id)
    end
  end

private

  def user_forums
    if @user.preferences.forums.include? Forum::MY_CLUBS_FORUM.permalink
      @scope
        .where(
          "#{FORUMS_QUERY} or #{MY_CLUBS_QUERY}",
          user_forums: @user.preferences.forums.map(&:to_i),
          user_club_ids: user_club_ids,
          user_club_page_ids: user_club_page_ids
        )
    else
      @scope
        .where(FORUMS_QUERY, user_forums: @user.preferences.forums.map(&:to_i))
    end
  end

  def guest_forums
    @scope.where(
      'type not in (?) OR type IS NULL', [
        Topics::EntryTopics::ClubTopic.name,
        Topics::ClubUserTopic.name,
        Topics::EntryTopics::ClubPageTopic.name
      ]
    )
  end

  def reviews_forums
    @scope
      .where(forum_id: @forum.id)
      .except(:order)
      .order(created_at: :desc)
  end

  def clubs_forums
    new_scope = @scope
      .where(forum_id: @forum.id)
      .where(linked_type: [Club.name, ClubPage.name])

    if @is_censored_forbidden
      new_scope
        .joins(CLUBS_JOIN)
        .where(
          CLUBS_WHERE,
          user_club_ids: user_club_ids,
          user_club_page_ids: user_club_page_ids
        )
    else
      new_scope
    end
  end

  def news_forums
    @scope
      .where(NEWS_QUERY)
      .except(:order)
      .order(created_at: :desc)
  end

  def updates_forums
    @scope
      .where(type: [Topics::NewsTopic.name], generated: true)
      .except(:order)
      .order(created_at: :desc)
  end

  def my_clubs_forums
    @scope.where(
      MY_CLUBS_QUERY,
      user_club_ids: user_club_ids,
      user_club_page_ids: user_club_page_ids
    )
  end

  def user_club_ids
    @user_club_ids ||= @user&.club_roles&.pluck(:club_id) || []
  end

  def user_club_page_ids
    @user_club_page_ids ||= ClubPage.where(club_id: user_club_ids).pluck(:id)
  end
end
