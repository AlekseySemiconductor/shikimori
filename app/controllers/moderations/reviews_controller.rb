# TODO: migrate to cancancan
class Moderations::ReviewsController < ModerationsController
  before_action :authenticate_user!
  before_action :check_permissions
  PENDING_PER_PAGE = 15

  def index
    @page_title = i18n_t 'page_title'

    @moderators = User.where(id: User::REVIEWS_MODERATORS - User::ADMINS).sort_by { |v| v.nickname.downcase }
    @processed = postload_paginate(params[:page], 25) do
      Review
        .where(state: ['accepted', 'rejected'])
        .includes(:user, :approver, :target, :topics)
        .order(created_at: :desc)
    end

    # if user_signed_in? && current_user.reviews_moderator?
    @pending = Review
      .where(state: 'pending')
      .includes(:user, :approver, :target, :topics)
      .order(created_at: :desc)
      .limit(PENDING_PER_PAGE)
    # end
  end

  def accept
    @review = Review.find params[:id].to_i
    @review.accept! current_user if @review.can_accept?

    redirect_back fallback_location: moderations_reviews_url
  end

  def reject
    @review = Review.find params[:id].to_i
    @review.reject! current_user if @review.can_reject?

    redirect_back fallback_location: moderations_reviews_url
  end

private
  def check_permissions
    raise Forbidden unless current_user.reviews_moderator?
  end
end
