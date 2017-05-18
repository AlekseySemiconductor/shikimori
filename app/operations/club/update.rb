# frozen_string_literal: true

class Club::Update < ServiceObjectBase
  pattr_initialize :model, :kick_ids, :params, :page

  ALLOWED_EXCEPTIONS = [PG::UniqueViolation, ActiveRecord::RecordNotUnique]

  def call
    kick_users
    Retryable.retryable tries: 2, on: ALLOWED_EXCEPTIONS, sleep: 1 do
      update_club
    end

    @model
  end

private

  def kick_users
    users_to_kick = User.where id: (@kick_ids || [])
    users_to_kick.each { |user| @model.leave user }
  end

  def update_club
    Club.transaction do
      cleaup_links if links_page?
      cleaup_members if members_page?

      @model.update @params
    end
  end

  def cleaup_links
    @model.links.where(linked_type: Anime.name).delete_all
    @model.links.where(linked_type: Manga.name).delete_all
    @model.links.where(linked_type: Ranobe.name).delete_all
    @model.links.where(linked_type: Character.name).delete_all
  end

  def cleaup_members
    @model.banned_users = []
    @model.member_roles.where(role: :admin).update_all role: :member
    @model.member_roles.where(user_id: @params[:admin_ids]).destroy_all
  end

  def links_page?
    @page == 'links'
  end

  def members_page?
    @page == 'members'
  end
end
