class Api::V1::CommentsController < Api::V1::ApiController
  respond_to :json

  before_filter :authenticate_user!, only: [:create, :update, :destroy]
  before_filter :check_post_permission, only: [:create, :update, :destroy]
  before_filter :prepare_edition, only: [:edit, :create, :update, :destroy]

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/comments/:id', 'Show a comment'
  def show
    respond_with Comment.find(params[:id]).decorate
  end

  api :GET, '/comments', 'List comments'
  param :commentable_id, :number, required: true
  param :commentable_type, String, required: true
  param :page, :number, required: false
  param :limit, :number, required: false
  param :desc, %w(1 0), required: false
  def index
    @limit = [[params[:limit].to_i, 1].max, 30].min
    @page = [params[:page].to_i, 1].max
    @desc = params[:desc].nil? || params[:desc] == '1'

    respond_with CommentsQuery
      .new(params[:commentable_type], params[:commentable_id])
      .fetch(@page, @limit, @desc)
      .with_viewed(current_user)
      .decorate
  end

  api :POST, '/comments', 'Create a comment'
  param :comment, Hash do
    param :body, String, required: true
    param :commentable_id, :number, required: true
    param :commentable_type, String, required: true
    param :is_offtopic, :bool, required: false
    param :is_summary, :bool, required: false
  end
  param :frontend, :bool
  def create
    @resource = Comment::Create.call(faye, create_params)
    if faye.create(@resource) && frontent_request?
      render :comment
    else
      respond_with @resource.decorate
    end
  end

  api :PATCH, '/comments/:id', 'Update a comment'
  api :PUT, '/comments/:id', 'Update a comment'
  param :comment, Hash do
    param :body, String, required: true
  end
  param :frontend, :bool
  def update
    raise CanCan::AccessDenied unless @resource.can_be_edited_by? current_user

    if faye.update(@resource, update_params) && frontent_request?
      render :comment
    else
      respond_with @resource.decorate
    end
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, '/comments/:id', 'Destroy a comment'
  def destroy
    raise CanCan::AccessDenied unless @resource.can_be_deleted_by? current_user
    faye.destroy @resource

    render json: { notice: i18n_t('comment.removed') }
  end

private

  # TODO: remove 'offtopic' and 'review' after 01.09.2016
  def comment_params
    comment_params = params
      .require(:comment)
      .permit(
        :body, :review, :offtopic, :is_summary, :is_offtopic,
        :commentable_id, :commentable_type, :user_id
      )

    comment_params[:is_summary] ||= comment_params[:review]
    comment_params[:is_offtopic] ||= comment_params[:offtopic]

    comment_params.except(:review, :offtopic)
  end

  def create_params
    comment_params.merge(user: current_user)
  end

  def update_params
    comment_params.except(:is_summary, :is_offtopic)
  end

  def prepare_edition
    @resource = Comment.find(params[:id]).decorate if params[:id]
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
