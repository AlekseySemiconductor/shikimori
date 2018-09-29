class UserHistoryController < ProfilesController
  before_action :check_access, only: %i[index logs]

  def index
    redirect_to @resource.url unless @resource.history.any?
    og noindex: true
    og page_title: i18n_t('page_title.history')

    @view = UserHistoryView.new @resource
  end

  def logs
    og noindex: true
    og page_title: i18n_t('page_title.logs')
    breadcrumb i18n_t('page_title.history'), profile_list_history_url(@resource)
    @back_url = profile_list_history_url(@resource)

    @page = (params[:page] || 1).to_i
    @limit = 45

    @collection = QueryObjectBase
      .new(@resource.user_rate_logs.order(id: :desc).includes(:target, :oauth_application))
      .paginate(@page, @limit)
  end

  def reset
    authorize! :edit, @resource

    @resource.object.history.where(target_type: params[:type].capitalize).delete_all
    @resource.object.history
      .where(
        action: [
          "mal_#{params[:type]}_import",
          "ap_#{params[:type]}_import",
          clear_action
        ]
      )
      .delete_all
    @resource.object.history.create! action: clear_action
    @resource.touch

    render json: {
      notice: "Выполнена очистка вашей истории по #{anime? ? 'аниме' : 'манге'}"
    }
  end

private

  def anime?
    params[:type] == 'anime'
  end

  def clear_action
    if anime?
      UserHistoryAction::AnimeHistoryClear
    else
      UserHistoryAction::MangaHistoryClear
    end
  end

  def check_access
    authorize! :access_list, @resource
  end
end
