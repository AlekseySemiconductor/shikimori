# refactor to models/concerns
module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, -> { order created_at: :desc },
      class_name: 'Comment',
      as: :commentable,
      inverse_of: :commentable,
      dependent: :destroy
  end
end
