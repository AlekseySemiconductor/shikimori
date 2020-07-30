class Api::V1::ShikiEditorsController < Api::V1Controller
  SUPPORTED_TYPES = %i[anime manga character person user_image comment message topic] # user
  TYPE_INCLUDES = {
    message: :from,
    comment: :user,
    topic: %i[user linked]
  }

  PER_REQUEST = 200

  def show # rubocop:disable all
    results = {}
    limit_left = PER_REQUEST

    SUPPORTED_TYPES.each do |kind|
      break if limit_left <= 0

      ids = parse_ids(kind, limit_left)
      limit_left -= ids.size

      next if ids.none?

      results[kind] = fetch(kind, ids).transform_values do |model|
        next unless model

        case kind
          when :user_image
            serialize_user_image model
          # when :user
          #   serialize_user model
          when :topic, :comment
            serialize_forum_entry model
          when :message
            serialize_message model
          else
            serialize_db_entry model
          end
      end
    end

    results[:is_paginated] = true if limit_left <= 0

    render json: results
  end

private

  def parse_ids kind, limit
    (params[kind] || '')
      .split(',')
      .uniq
      .map(&:to_i)
      .select { |v| v.present? && v.positive? }
      .take(limit)
  end

  def fetch kind, ids
    results = ids.sort.each_with_object({}) { |id, memo| memo[id] = nil }

    kind.to_s.classify.constantize
      .includes(TYPE_INCLUDES[kind])
      .where(id: ids)
      .each_with_object(results) do |model, memo|
        memo[model.id] = model
      end
  end

  def serialize_user_image model
    {
      id: model.id,
      url: ImageUrlGenerator.instance.url(model, :original)
      # original_url: model.image.url(:original),
      # preview_url: model.image.url(:preview),
      # width: model.width,
      # height: model.height
    }
  end

  # def serialize_user model
  #   {
  #     id: model.id,
  #     nickname: model.nickname,
  #     avatar: ImageUrlGenerator.instance.url(model, :x32),
  #     url: profile_url(model)
  #   }
  # end

  def serialize_forum_entry model
    {
      id: model.id,
      text: model.user.nickname,
      url: model.is_a?(Comment) ?
        UrlGenerator.instance.comment_url(model) :
        UrlGenerator.instance.topic_url(model)
    }
  end

  def serialize_message model
    # return unless can? :read, model

    {
      id: model.id,
      text: model.from.nickname,
      url: profile_url(model.from)
    }
  end

  def serialize_db_entry model
    {
      id: model.id,
      text: UsersHelper.localized_name(model, current_user),
      url: UrlGenerator.instance.send(:"#{model.class.name.downcase}_url", model)
    }
  end
end
