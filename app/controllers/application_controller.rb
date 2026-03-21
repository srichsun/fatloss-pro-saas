class ApplicationController < ActionController::Base

end



class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Ensure every request is scoped to a tenant before reaching the action
  before_action :set_current_tenant

  private

  def set_current_tenant
    # Find tenant by ID or Subdomain from params
    # In a real SaaS, this would often come from the request's subdomain
    @current_tenant = Tenant.find_by(id: params[:tenant_id]) || Tenant.find_by(subdomain: params[:subdomain])
    
    # Security Gate: Redirect to root if tenant is missing and not on the landing page
    if @current_tenant.nil? && !is_root_path?
      redirect_to root_path, alert: "Please select a valid coach link."
    end
  end

  def is_root_path?
    request.path == "/"
  end

  # Helper method to access the current tenant in controllers and views
  def current_tenant
    @current_tenant
  end
  helper_method :current_tenant
end