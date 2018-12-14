# TODO: remove `unless params[:user_id]` after 01-09-2017
class Api::V2::UserRatesController < Api::V2Controller
  skip_before_action :verify_authenticity_token
  load_and_authorize_resource

  MAX_LIMIT = 1000
  UNIQ_EXCEPTIONS = Api::V1::UserRatesController::UNIQ_EXCEPTIONS

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/v2/user_rates/:id', 'Show an user rate'
  def show
    respond_with @resource
  end

  api :GET, '/v2/user_rates', 'List user rates'
  param :user_id, :number, required: false
  param :target_id, :number, required: false
  param :target_type, %w[Anime Manga], required: false
  param :status, :undef,
    required: false,
    desc: I18n.t('activerecord.attributes.user_rate.statuses.anime', locale: :en)
      .map { |(k, v)| "<p><code>#{k}</code> &ndash; #{ERB::Util.h v}</p>" }
      .join('') + <<~DOC
        <p><strong>Validations:</strong></p>
        <ul>
          <li>
            Must be one of:
            <code>#{UserRate.statuses.keys.join '</code>, <code>'}</code>
          </li>
        </ul>
      DOC
  param :page, :pagination,
    required: false,
    desc: 'This field is ignored when user_id is set'
  param :limit, :pagination,
    required: false,
    desc: "#{MAX_LIMIT} maximum. This field is ignored when user_id is set"
  def index
    limit = [[params[:limit].to_i, 1].max, MAX_LIMIT].min
    page = [params[:page].to_i, 1].max

    if params[:target_id].present? && params[:target_type].blank?
      raise MissingApiParameter, 'target_type'
    end

    if %i[target_type target_id user_id].all? { |field| params[field].blank? }
      raise MissingApiParameter, 'user_id'
    end

    scope = %i[user_id status target_type target_id]
      .each_with_object(UserRate.all) do |field, local_scope|
        if params[field].present?
          local_scope.where! field => params[field].split(',').take(10)
        end
      end

    # TODO: remove `unless params[:user_id]` after 01-09-2017
    scope.offset!(limit * (page - 1)).limit!(limit) unless params[:user_id]

    @collection = Rails.cache.fetch(scope) { scope.to_a }

    respond_with @collection
  end

  api :POST, '/v2/user_rates', 'Create an user rate'
  param :user_rate, Hash do
    param :user_id, :number, required: true
    param :target_id, :number, required: true
    param :target_type, %w[Anime Manga], required: true
    param :status, :undef, required: false
    # param :status, UserRate.statuses.keys, required: true
    param :score, :undef, required: false
    param :chapters, :undef, required: false
    param :episodes, :undef, required: false
    param :volumes, :undef, required: false
    param :rewatches, :undef, required: false
    param :text, String, required: false
  end
  def create
    Retryable.retryable tries: 2, on: UNIQ_EXCEPTIONS, sleep: 1 do
      present_rate = UserRate.find_by(
        user_id: @resource.user_id,
        target_id: @resource.target_id,
        target_type: @resource.target_type
      )

      if present_rate
        update_rate present_rate
      else
        create_rate @resource
      end
    end

    respond_with @resource
  end

  api :PATCH, '/v2/user_rates/:id', 'Update an user rate'
  api :PUT, '/v2/user_rates/:id', 'Update an user rate'
  param :user_rate, Hash do
    param :status, :undef, required: false
    # param :status, UserRate.statuses.keys, required: false
    param :score, :undef, required: false
    param :chapters, :undef, required: false
    param :episodes, :undef, required: false
    param :volumes, :undef, required: false
    param :rewatches, :undef, required: false
    param :text, String, required: false
  end
  def update
    update_rate @resource
    respond_with @resource, location: nil
  end

  api :POST, '/v2/user_rates/:id/increment', 'Increment episodes/chapters by 1'
  def increment
    @resource.update increment_params
    log @resource

    if @resource.anime?
      Achievements::Track.perform_async(
        @resource.user_id,
        @resource.id,
        Types::Neko::Action[:put]
      )
    end
    respond_with @resource, location: nil
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :DELETE, '/v2/user_rates/:id', 'Destroy an user rate'
  def destroy
    @resource.destroy!
    log @resource

    if @resource.anime?
      Achievements::Track.perform_async(
        @resource.user_id,
        @resource.id,
        Types::Neko::Action[:delete]
      )
    end

    head 204
  end

private

  def create_params
    params
      .require(:user_rate)
      .permit(*Api::V1::UserRatesController::CREATE_PARAMS)
  end

  def update_params
    params
      .require(:user_rate)
      .permit(*Api::V1::UserRatesController::UPDATE_PARAMS)
  end

  def increment_params
    if @resource.anime?
      { episodes: (params[:episodes] || @resource.episodes) + 1 }
    else
      { chapters: (params[:chapters] || @resource.chapters) + 1 }
    end
  end

  def create_rate user_rate
    @resource = user_rate
    raise NotSaved unless @resource.save

    log @resource

    if @resource.anime? && @resource.completed?
      Achievements::Track.perform_async(
        @resource.user_id,
        @resource.id,
        Types::Neko::Action[:put]
      )
    end
  rescue *Api::V1::UserRatesController::ALLOWED_EXCEPTIONS
    nil
  end

  def update_rate user_rate
    @resource = user_rate
    raise NotSaved unless @resource.update update_params

    log @resource

    if @resource.anime?
      Achievements::Track.perform_async(
        @resource.user_id,
        @resource.id,
        Types::Neko::Action[:put]
      )
    end
  rescue *Api::V1::UserRatesController::ALLOWED_EXCEPTIONS
    nil
  end

  def log user_rate
    UserRates::Log.call(
      user_rate: user_rate,
      ip: remote_addr,
      user_agent: request.user_agent,
      oauth_application_id: doorkeeper_token&.application_id
    )
  end
end
