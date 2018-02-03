class CollectionsController < ShikimoriController
  load_and_authorize_resource :collection, except: %i[index]

  before_action { page_title i18n_i('Collection', :other) }
  before_action :set_breadcrumbs, except: :index
  before_action :resource_redirect, if: :resource_id

  UPDATE_PARAMS = %i[name text state] + [
    links: %w[linked_id group text]
  ]
  CREATE_PARAMS = %i[user_id kind] + UPDATE_PARAMS

  # rubocop:disable AbcSize
  def index
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, 4].max, 8].min

    @collection = Collections::Query.fetch(locale_from_host)
      .search(params[:search], locale_from_host)
      .paginate(@page, @limit)
      .transform do |collection|
        Topics::TopicViewFactory
          .new(true, true)
          .build(collection.maybe_topic(locale_from_host))
      end

    if @page == 1 && params[:search].blank? && user_signed_in?
      @unpublished_collections = current_user.collections.unpublished
    end
  end
  # rubocop:enable AbcSize

  def show
    raise ActiveRecord::RecordNotFound unless @resource.published?

    og page_title: @resource.name
    @topic_view = Topics::TopicViewFactory
      .new(false, false)
      .build(@resource.maybe_topic(locale_from_host))
  end

  def new
    og page_title: i18n_t('new_collection')
    render :form
  end

  def create
    @resource = Collection::Create.call create_params, locale_from_host

    if @resource.errors.blank?
      redirect_to edit_collection_url(@resource),
        notice: i18n_t('collection_created')
    else
      new
    end
  end

  def edit
    og page_title: @resource.name
    @page = params[:page]
    render :form
  end

  def update
    Collection::Update.call @resource, update_params

    if @resource.errors.blank?
      redirect_to edit_collection_url(@resource), notice: t('changes_saved')
    else
      flash[:alert] = t('changes_not_saved')
      edit
    end
  end

  def destroy
    @resource.destroy!

    if request.xhr?
      render json: { notice: i18n_t('collection_deleted') }
    else
      redirect_to collections_url, notice: i18n_t('collection_deleted')
    end
  end

private

  def set_breadcrumbs
    breadcrumb i18n_i('Collection', :other), collections_url

    if %w[edit update].include? params[:action]
      breadcrumb(
        @resource.name,
        @resource.published? ? collection_url(@resource) :
          edit_collection_url(@resource)
      )
    end
  end

  def create_params
    params.require(:collection).permit(*CREATE_PARAMS)
  end
  alias new_params create_params

  def update_params
    params.require(:collection).permit(*UPDATE_PARAMS)
  end
end
