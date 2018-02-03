class DbEntriesController < ShikimoriController
  before_action :authenticate_user!, only: %i[edit edit_field update]

  # it must be always before :fetch_resource
  before_action { og page_title: resource_klass.model_name.human }
  before_action :fetch_resource, if: :resource_id
  before_action :og_db_entry_meta, if: :resource_id

  COLLETIONS_PER_PAGE = 4

  def tooltip
    og noindex: true
  end

  def versions
  end

  def collections
    if @resource.collections_scope.none?
      return redirect_to @resource.url, status: 301
    end
    og noindex: true, page_title: t('in_collections')

    page = [params[:page].to_i, 1].max

    @collection = Collections::Query.fetch(locale_from_host)
      .where(id: @resource.collections_scope)
      .paginate(page, COLLETIONS_PER_PAGE)
      .transform do |collection|
        Topics::TopicViewFactory
          .new(true, true)
          .build(collection.maybe_topic(locale_from_host))
      end
  end

  def edit
    og noindex: true, page_title: i18n_t('entry_edit')
  end

  def edit_field
    og noindex: true, page_title: i18n_t('entry_edit')
    @field = params[:field]

    authorize! :create, temp_verison
    if significant_fields.include? @field
      authorize! :significant_change, temp_verison
    end

    render template: 'db_entries/edit_field'
  end

  def update
    if (update_params.keys & significant_fields).any?
      authorize! :significant_change, temp_verison
    end

    Version.transaction do
      @version = if update_params[:image]
        update_image
      elsif update_params[:external_links]
        update_external_links
      else
        update_version
      end

      authorize! :create, @version
    end

    if @version.persisted?
      redirect_to(
        @resource.edit_url,
        notice: i18n_t("version_#{@version.state}")
      )
    else
      redirect_back(
        fallback_location: @resource.edit_url,
        alert: i18n_t('no_changes')
      )
    end
  end

private

  def og_db_entry_meta
    og description: @resource.description_meta
    og image: ImageUrlGenerator.instance.url(@resource, :original)
  end

  def significant_fields
    @resource.object.class::SIGNIFICANT_FIELDS.select do |field|
      field != 'image' || @resource.image.exists?
    end
  end

  def update_version
    version = Versioneers::FieldsVersioneer
      .new(@resource.object)
      .premoderate(
        update_params.is_a?(Hash) ? update_params : update_params.to_unsafe_h,
        current_user,
        params[:reason]
      )

    version.accept current_user if version.persisted? && can?(:accept, version)
    version
  end

  def update_image
    versioneer = Versioneers::PostersVersioneer.new(@resource.object)

    if can? :significant_change, @resource.object
      versioneer.postmoderate(
        update_params[:image],
        current_user,
        params[:reason]
      )
    else
      versioneer.premoderate(
        update_params[:image],
        current_user,
        params[:reason]
      )
    end
  end

  def update_external_links
    version = Versioneers::CollectionVersioneer
      .new(@resource.object, :external_links)
      .premoderate(
        update_params[:external_links].map(&:to_unsafe_h),
        current_user,
        params[:reason]
      )

    version.accept current_user if version.persisted? && can?(:accept, version)
    version
  end

  def temp_verison
    Version.new(
      user: current_user,
      item: @resource.decorated? ? @resource.object : @resource,
      item_diff: {}
    )
  end
end
