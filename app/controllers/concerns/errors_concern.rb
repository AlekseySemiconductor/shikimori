module ErrorsConcern
  extend ActiveSupport::Concern

  NOT_FOUND_ERRORS = [
    ActionController::RoutingError,
    ActiveRecord::RecordNotFound,
    AbstractController::ActionNotFound,
    ActionController::UnknownFormat
  ]

  included do
    unless Rails.env.test?
      rescue_from Exception, with: :runtime_error
    else
      rescue_from StatusCodeError, with: :runtime_error
    end
  end

  # rubocop:disable MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity
  def runtime_error error
    if defined? Airbrake
      Airbrake.notify error,
        url: request.url,
        session: JSON.parse(session.to_json),
        cookies: JSON.parse(cookies.to_json)
    end
    Honeybadger.notify error if defined? Honeybadger
    Raven.capture_exception error if defined? Raven
    Appsignal.set_error error if defined? Appsignal
    Bugsnag.notify error if defined? Bugsnag

    # NamedLogger
      # .send("#{Rails.env}_errors")
      # .error("#{error.message}\n#{e.backtrace.join("\n")}")
    # Rails.logger.error("#{error.message}\n#{e.backtrace.join("\n")}")

    raise error if local_addr? && (
      !error.is_a?(AgeRestricted) &&
      !error.is_a?(CopyrightedResource) &&
      !error.is_a?(Forbidden)
    )

    if NOT_FOUND_ERRORS.include? error.class
      not_found_error(error)

    elsif error.is_a?(AgeRestricted)
      age_restricted_error(error)

    elsif error.is_a?(Forbidden) || e.is_a?(CanCan::AccessDenied)
      forbidden_error(error)

    elsif error.is_a?(StatusCodeError)
      status_code_error(error)

    elsif error.is_a?(CopyrightedResource)
      copyrighted_error(error)

    elsif is_a?(Api::V1Controller) || json?
      api_error(error)

    else
      standard_error(error)
    end
  end
  # rubocop:enable MethodLength, AbcSize, CyclomaticComplexity, PerceivedComplexity

private

  def not_found_error _e
    if error_json_response?
      render json: { message: t('page_not_found'), code: 404 }, status: 404
    else
      render 'pages/page404', layout: false, status: 404, formats: :html
    end
  end

  def age_restricted_error _e
    render 'pages/age_restricted', layout: false, formats: :html
  end

  def forbidden_error error
    if error_json_response?
      render json: { message: error.message, code: 403 }, status: 403
    else
      render plain: error.message, status: 403
    end
  end

  def status_code_error error
    render json: {}, status: error.status
  end

  def copyrighted_error error
    resource = error.resource
    @new_url = url_for safe_params.merge(resource_id_key => resource.to_param)

    if params[:format] == 'rss'
      redirect_to @new_url, status: 301
    else
      render 'pages/page_moved.html', layout: false, status: 404, formats: :html
    end
  end

  def api_error error
    render(
      json: {
        code: 503,
        exception: error.class.name,
        message: error.message,
        backtrace: error.backtrace.first.sub(Rails.root.to_s, '')
      },
      status: 503
    )
  end

  def standard_error _e
    og page_title: t('error')
    render 'pages/page503.html', layout: false, status: 503, formats: :html
  end

  def error_json_response?
    json? || (is_a?(Api::V1Controller) && !params[:frontend])
  end
end
