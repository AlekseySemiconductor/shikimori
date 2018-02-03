class Users::ListImportsController < ProfilesController
  load_and_authorize_resource
  before_action do
    @back_url = edit_profile_url @user, page: :list
    breadcrumb t(:settings), edit_profile_url(@user, page: :list)
    og page_title: t(:settings)
  end

  def new
    og page_title: i18n_t(:title)
  end

  def create
    if @resource.save
      redirect_to profile_list_import_url(@user, @resource)
    else
      new
      render :new
    end
  end

  def show
    @view = ListImportView.new @resource
  end

private

  def list_import_params
    params
      .require(:list_import)
      .permit(:user_id, :list, :duplicate_policy, :list_type)
  end
end
