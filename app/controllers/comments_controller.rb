class CommentsController < ShikimoriController
  include CommentHelper

  before_filter :authenticate_user!, only: [:edit, :create, :update, :destroy]
  before_filter :check_post_permission, only: [:create, :update, :destroy]
  before_filter :prepare_edition, only: [:edit, :create, :update, :destroy]

  def show
    noindex
    comment = Comment.find_by(id: params[:id]) || NoComment.new(params[:id])
    @view = Comments::View.new comment, false

    render :missing if comment.is_a? NoComment
  end

  def reply
    comment = Comment.find params[:id]
    @view = Comments::View.new comment, true
    render :show
  end

  def edit
    @comment = Comment.find params[:id]
  end

  # динамическая подгрузка комментариев при скролле
  def postloader
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @offset = params[:offset].to_i
    @page = (@offset+@limit) / @limit

    @comments, @add_postloader = CommentsQuery
      .new(params[:commentable_type], params[:commentable_id], params[:is_summary].present?)
      .postload(@page, @limit, true)
  end

  # все комментарии сущности до определённого коммента
  def fetch
    comment = Comment.find(params[:comment_id])
    entry = params[:topic_type].constantize.find(params[:topic_id])

    raise Forbidden unless comment.commentable_id == entry.id && (
                             comment.commentable_type == entry.class.name || (
                               entry.respond_to?(:base_class) && comment.commentable_type == entry.base_class.name
                           ))
    from = params[:skip].to_i
    to = [params[:limit].to_i, 100].min

    query = entry
      .comments
      .with_viewed(current_user)
      .includes(:user, :commentable)
      .offset(from)
      .limit(to)

    query.where! is_summary: true if params[:is_summary]

    @collection = query
      .decorate
      .reverse

    render :collection, formats: :json
    # render partial: 'comments/comment', collection: comments, formats: :html
  end

  # список комментариев по запросу
  def chosen
    comments = Comment
      .with_viewed(current_user)
      .where(id: params[:ids].split(',').map(&:to_i))
      .includes(:user, :commentable)
      .limit(100)
      .decorate

    @collection = params[:order] ? comments.reverse : comments

    render :collection, formats: :json
  end

  # предпросмотр текста
  def preview
    @comment = Comment.new(comment_params).decorate

    # это может быть предпросмотр не просто текста, а описания к аниме или манге
    if params[:comment][:target_type] && params[:comment][:target_id]
      @comment = DescriptionComment.new(@comment,
        params[:comment][:target_type], params[:comment][:target_id])
    end

    render @comment
  end

  # смайлики для комментария
  def smileys
    render partial: 'comments/smileys'
  end

private

  def prepare_edition
    Rails.logger.info params.to_yaml
    @comment = Comment.find(params[:id]).decorate if params[:id]
  end

  def faye
    FayeService.new current_user, faye_token
  end

  def comment_params
    params
      .require(:comment)
      .permit(:body, :is_summary, :is_offtopic, :commentable_id, :commentable_type, :user_id)
  end
end
