class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def after_sign_in_path_for(resource)
    authenticated_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    unauthenticated_root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [
        :first_name,
        :last_name,
        :phone,
        :document
      ]
    )
  end
end
