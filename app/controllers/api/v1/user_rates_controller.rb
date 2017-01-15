class Api::V1::UserRatesController < Api::V1Controller
  load_and_authorize_resource

  CREATE_PARAMS = %i(
    target_id target_type user_id status episodes chapters volumes score text
    rewatches
  )
  UPDATE_PARAMS = %i(status episodes chapters volumes score text rewatches)

  UNIQ_EXCEPTIONS = [ActiveRecord::RecordNotUnique, PG::UniqueViolation]
  ALLOWED_EXCEPTIONS = [PG::Error, RangeError, NotSaved]

  api :GET, '/user_rates/:id', 'Show an user rate', deprecated: true
  def show
    respond_with @resource
  end

  api :POST, '/user_rates', 'Create an user rate', deprecated: true
  param :user_rate, Hash do
    param :user_id, :number, required: true
    param :target_id, :number, required: true
    param :target_type, %w(Anime Manga), required: true
    param :status, :undef, required: true
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

    respond_with @resource, location: nil, serializer: UserRateFullSerializer
  end

  api :PATCH, '/user_rates/:id', 'Update an user rate', deprecated: true
  api :PUT, '/user_rates/:id', 'Update an user rate', deprecated: true
  param :user_rate, Hash do
    param :status, :undef, required: false
    param :score, :undef, required: false
    param :chapters, :undef, required: false
    param :episodes, :undef, required: false
    param :volumes, :undef, required: false
    param :rewatches, :undef, required: false
    param :text, String, required: false
  end
  def update
    update_rate @resource
    respond_with @resource, location: nil, serializer: UserRateFullSerializer
  end

  api :POST, '/user_rates/:id/increment', deprecated: true
  def increment
    @resource.update increment_params
    respond_with @resource, location: nil, serializer: UserRateFullSerializer
  end

  api :DELETE, '/user_rates/:id', 'Destroy an user rate', deprecated: true
  def destroy
    @resource.destroy!
    head 204
  end

  # очистка списка и истории
  api :DELETE, "/user_rates/:type/cleanup", "Delete entire user rates and history"
  def cleanup
    user = current_user.object

    user.history.where(target_type: params[:type].capitalize).delete_all
    user.history.where(action: "mal_#{params[:type]}_import").delete_all
    user.history.where(action: "ap_#{params[:type]}_import").delete_all
    user.send("#{params[:type]}_rates").delete_all
    user.touch

    render json: { notice: i18n_t("list_and_history_cleared.#{params[:type]}") }
  end

  # сброс оценок в списке
  api :DELETE, "/user_rates/:type/reset", "Reset all user scores to 0"
  def reset
    current_user.send("#{params[:type]}_rates").update_all score: 0
    current_user.touch

    render json: { notice: i18n_t("scores_reset.#{params[:type]}") }
  end

private

  def create_params
    params.require(:user_rate).permit(*CREATE_PARAMS)
  end

  def update_params
    params.require(:user_rate).permit(*UPDATE_PARAMS)
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
  rescue *ALLOWED_EXCEPTIONS
  end

  def update_rate user_rate
    @resource = user_rate
    raise NotSaved unless @resource.update update_params
  rescue *ALLOWED_EXCEPTIONS
  end
end
