# frozen_string_literal: true

class ClubsController < ShikimoriController
  load_and_authorize_resource :club, except: %i[index autocomplete]

  before_action { page_title i18n_i('Club', :other) }

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: :resource_id
  before_action :restrict_domain, except: %i[index create new autocomplete]

  before_action :set_breadcrumbs

  UPDATE_PARAMS = [
    :name,
    :join_policy,
    :description,
    :display_images,
    :comment_policy,
    :topic_policy,
    :image_upload_policy,
    :logo,
    :is_censored,
    anime_ids: [],
    manga_ids: [],
    ranobe_ids: [],
    character_ids: [],
    club_ids: [],
    admin_ids: [],
    banned_user_ids: []
  ]
  CREATE_PARAMS = %i[owner_id] + UPDATE_PARAMS

  def index
    noindex
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, 24].max, 48].min

    query = Clubs::Query.fetch(locale_from_host)

    if params[:search].blank?
      @favourites = query.favourites if @page == 1
      query = query.without_favourites
    end

    @collection = query
      .search(params[:search], locale_from_host)
      .paginate(@page, @limit)
  end

  def show
    noindex
  end

  def new
    page_title i18n_t('new_club')
    @resource = @resource.decorate
  end

  def create
    @resource = Club::Create.call create_params, locale_from_host

    if @resource.errors.blank?
      redirect_to edit_club_url(@resource, page: 'main'),
        notice: i18n_t('club_created')
    else
      new
      render :new
    end
  end

  def edit
    page_title t(:settings)
    page_title t("clubs.page.pages.#{params[:page]}")
    @page = params[:page]
  end

  def update
    Club::Update.call @resource, params[:kick_ids], update_params, params[:page]

    if @resource.errors.blank?
      redirect_to edit_club_url(@resource, page: params[:page]),
        notice: t('changes_saved')
    else
      flash[:alert] = t('changes_not_saved')
      edit
      render :edit
    end
  end

  def members
    noindex
    page_title i18n_t('club_members')

    roles = postload_paginate(params[:page], 48) do
      @resource.all_member_roles
    end
    @collection = roles.map(&:user)
  end

  def animes
    noindex
    redirect_to club_url(@resource) if @resource.animes.none?
    page_title i18n_t('club_anime')
  end

  def mangas
    noindex
    redirect_to club_url(@resource) if @resource.mangas.none?
    page_title i18n_t('club_manga')
  end

  def ranobe
    noindex
    redirect_to club_url(@resource) if @resource.ranobe.none?
    page_title i18n_t('club_ranobe')
  end

  def characters
    noindex
    redirect_to club_url(@resource) if @resource.characters.none?
    page_title i18n_t('club_characters')
  end

  def images
    noindex
    page_title i18n_t('club_images')
  end

  def autocomplete
    @collection = Clubs::Query.fetch(locale_from_host)
      .search(params[:search], locale_from_host)
      .paginate(1, CompleteQuery::AUTOCOMPLETE_LIMIT)
      .reverse
  end

private

  def restrict_domain
    raise ActiveRecord::RecordNotFound if @resource.locale != locale_from_host
  end

  def resource_klass
    Club
  end

  def set_breadcrumbs
    breadcrumb i18n_i('Club', :other), clubs_url

    if resource_id.present? && params[:action] != 'show'
      breadcrumb @resource.name, club_url(@resource)
    end
  end

  def create_params
    params.require(:club).permit(*CREATE_PARAMS)
  end
  alias new_params create_params

  def update_params
    params[:club] ? params.require(:club).permit(*UPDATE_PARAMS) : {}
  end
end
