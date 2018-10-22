class MessagesController < ProfilesController
  load_and_authorize_resource(
    except: %i[index feed preview read_all delete_all chosen unsubscribe]
  )

  skip_before_action :fetch_resource, :set_breadcrumbs,
    except: %i[index read_all delete_all]
  before_action :authorize_acess, only: %i[index read_all delete_all]

  MESSAGES_PER_PAGE = 15

  def index
    @page = [params[:page].to_i, 1].max
    @limit = [
      [params[:limit].to_i, MESSAGES_PER_PAGE].max,
      MESSAGES_PER_PAGE * 2
    ].min

    @collection, @add_postloader =
      MessagesQuery.new(@resource, @messages_type).postload @page, @limit
    @collection = @collection.map(&:decorate)

    og page_title: localized_page_title
  end

  def show
    @resource = @resource.decorate
  end

  def edit
  end

  def preview
    message = Message.new(create_params).decorate
    render message
  end

  def chosen
    @collection = Message
      .where(id: params[:ids].split(',').map(&:to_i))
      .includes(:from, :to, :linked)
      .order(:id)
      .limit(100)
      .select { |message| can? :read, message }
      .map(&:decorate)

    render :index, formats: :json
  end

  def unsubscribe # rubocop:disable AbcSize
    @user = User.find_by! nickname: User.param_to(params[:name])
    if self.class.unsubscribe_key(@user, params[:kind]) != params[:key]
      raise CanCan::AccessDenied
    end

    if @user.notification_settings_private_message_email?
      @user.update!(
        notification_settings: @user.notification_settings.values -
          [Types::User::NotificationSettings[:private_message_email].to_s]
      )
    end

    og page_title: @user.nickname
    og page_title: i18n_t('unsubscribe')
  end

  # rss лента уведомлений
  def feed
    @user = User.find_by! nickname: User.param_to(params[:name])
    raise CanCan::AccessDenied if self.class.rss_key(@user) != params[:key]

    raw_messages = Rails.cache.fetch(
      "notifications_feed_#{@user.id}",
      expires_in: 60.minutes
    ) do
      Message
        .where(to_id: @user.id)
        .where.not(kind: MessageType::Private)
        .order(:read, created_at: :desc)
        .includes(:linked)
        .limit(25)
        .decorate
        .reject(&:broken?)
        .to_a
    end

    @messages = raw_messages.map do |message|
      if message.linked&.respond_to?(:linked) && message.linked&.linked
        linked = message.linked.linked
      end

      {
        entry: message.decorate,
        guid: "message-#{message.id}",
        image_url: linked&.image&.exists? ?
          '//shikimori.org' + linked.image.url(:preview, false) :
          nil,
        link: linked ? url_for(linked) : messages_url(type: :notifications),
        linked_name: linked ? linked.name : nil,
        pubDate: Time.at(message.created_at.to_i).to_s(:rfc822),
        title: linked ? linked.name : i18n_i('Site')
      }
    end
    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
    render 'messages/feed', formats: :rss
  end

  # ключ к rss ленте уведомлений
  def self.rss_key user
    Digest::SHA1.hexdigest("notifications_feed_for_user_##{user.id}!")
  end

  # ключ к отписке от сообщений
  def self.unsubscribe_key user, kind
    Digest::SHA1.hexdigest("unsubscribe_#{kind}_messages_for_user_##{user.id}!")
  end

private

  def localized_page_title
    if @messages_type == :news
      i18n_t '.site_news'
    elsif @messages_type == :private
      i18n_t '.private_messages'
    else
      i18n_t '.site_notifications'
    end
  end

  def create_params
    params.require(:message).permit(:body, :from_id, :to_id, :kind)
  end

  def authorize_acess
    authorize! :access_messages, @resource
    @messages_type = params[:messages_type].to_sym
  end
end
