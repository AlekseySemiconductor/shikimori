class DashboardsController < ShikimoriController
  before_action do
    # @view = current_user&.preferences&.dashboard_type_new? ?
    #   DashboardViewV2.new :
    #   DashboardView.new
    @view = DashboardViewV2.new
  end

  def show
    og type: 'website'
    og page_title: i18n_t('page_title')
    og description: i18n_t('description')
    og image: "#{Shikimori::PROTOCOL}://#{Shikimori::DOMAIN}" \
      '/favicons/opera-icon-228x228.png'

    if @view.is_a? DashboardViewV2
      render :show_v2
    else
      render :show
    end
  end

  def dynamic
  end
end
