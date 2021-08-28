class Users::PasswordsController < Devise::PasswordsController
  include ApplicationHelper
  prepend_before_action :check_captcha, only: %i[create] # rubocop:disable LexicallyScopedActionFilter
  skip_before_action :require_no_authentication

  def new
    email = params.dig(:user, :email)
    if email.present?
      self.resource = resource_class.new email: email
    else
      super
    end
  end

  def update
    super do |user|
      bypass_sign_in user if user.errors.none? && user_signed_in?
    end
  end

private

  def after_sending_reset_password_instructions_path_for(resource_name)
    if user_signed_in?
      edit_profile_url current_user, section: :account
    else
      super
    end
  end

  def check_captcha
    auto_success = verify_recaptcha action: 'forgot', minimum_score: 0.5,
      secret_key: Rails.application.secrets.recaptcha[:v3][:secret_key]
    checkbox_success = verify_recaptcha unless auto_success

    unless auto_success || checkbox_success
      @show_checkbox_recaptcha = true
      self.resource = resource_class.new email: params.dig(:user, :email)
      # resource.validate # Look for any other validation errors besides Recaptcha
      respond_with_navigational(resource) { render :new }
    end
  end
end
