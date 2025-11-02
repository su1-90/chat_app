class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActiveRecord::RecordNotDestroyed, with: :render_422

  class NotAuthorizedError < StandardError; end
  rescue_from NotAuthorizedError, with: :render_403

  private

  def render_403
    render file: Rails.root.join("public/403.html"), status: :forbidden, layout: false
  end

  def render_404
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  def render_422
    render file: Rails.root.join("public/422.html"), status: :unprocessable_entity, layout: false
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end
end