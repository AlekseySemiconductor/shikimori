class ScreenshotsController < ShikimoriController
  before_action :authenticate_user!
  before_action :fetch_anime

  def create
    @screenshot, @version = versioneer.upload params[:image], current_user

    if @screenshot.persisted?
      render json: {
        html: render_to_string(@screenshot, locals: { edition: true })
      }
    else
      render json: @screenshot.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @screenshot = Screenshot.find(params[:id])

    if @screenshot.status == Screenshot::UPLOADED
      @screenshot.destroy
      render json: { notice: i18n_t('screenshot_deleted') }
    else
      @version = versioneer.delete @screenshot.id, current_user

      if @version.persisted?
        render json: { notice: i18n_t('pending_version') }
      else
        render json: @version.errors.full_messages, status: :unprocessable_entity
      end
    end
  end

  def reposition
    @version = versioneer.reposition params[:ids].split(','), current_user

    redirect_back(
      fallback_location: @anime.decorate.edit_field_url(:screenshots),
      notice: i18n_t('pending_version')
    )
  end

private

  def versioneer
    Versioneers::ScreenshotsVersioneer.new @anime
  end

  def fetch_anime
    @anime = Anime.find(
      CopyrightedIds.instance.restore(params[:anime_id], 'anime')
    )
  end
end
