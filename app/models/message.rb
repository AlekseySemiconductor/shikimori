# TODO: refactor kind = MessageType::... into enumerize kind or into enum kind
class Message < ApplicationRecord
  include AntispamConcern
  include Translation

  belongs_to :from, class_name: User.name
  belongs_to :to, class_name: User.name
  belongs_to :linked, polymorphic: true, optional: true

  antispam(
    interval: 3.seconds,
    disable_if: -> { kind != MessageType::PRIVATE || from.bot? },
    user_id_key: :from_id
  )

  validates :from, :to, presence: true
  validates :body,
    presence: true,
    if: -> { kind == MessageType::PRIVATE }

  before_create :check_spam_abuse,
    if: -> { kind == MessageType::PRIVATE && !from.bot? }
  after_create :send_email
  after_create :send_push_notifications

  def new? params
    %w[
      inbox
      news
      notifications
    ].include?(params[:type]) && !read
  end

  def html_body
    BbCodes::Text.call body
  end

  def delete_by user
    if kind == MessageType::PRIVATE && to == user
      update! is_deleted_by_to: true, read: true
    else
      destroy!
    end

    self
  end

  # for rss feed
  def guid
    "message-#{id}"
  end

  def read?
    read
  end

private

  def check_spam_abuse
    throw :abort unless Messages::CheckSpamAbuse.call(self)

    unless Users::CheckHacked.call(model: self, text: body, user: from)
      throw :abort
    end
  end

  def send_email
    return unless kind == MessageType::PRIVATE

    EmailNotifier.instance.private_message self
  end

  def send_push_notifications
    return unless to.active?

    to.devices.each do |device|
      PushNotification.perform_async id, device.id
    end
  end
end
