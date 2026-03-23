class ApplicationController < ActionController::Base
  # Rails 8 default: Only allow modern browsers
  allow_browser versions: :modern
  stale_when_importmap_changes

  # Core SaaS security gates
  before_action :set_current_tenant
  
  # Define helper methods for use in Views and Controllers
  helper_method :current_user, :logged_in?, :current_tenant

  private

  # 1. Authentication Logic (Session Handling)
  def current_user
    # Use memoization to prevent redundant DB lookups in a single request
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  # Use this in sub-controllers (e.g., Dashboards) to force login
  def authenticate_user!
    unless logged_in?
      # Store the intended URL to redirect back after login (Standard UX)
      session[:return_to] = request.fullpath
      redirect_to login_path, alert: "Please sign in to continue."
    end
  end

  # 2. Tenant Scoping & Security Logic 
  def set_current_tenant
    subdomain_in_url = params[:subdomain].to_s.strip
    
    # 1. Find the target tenant room
    @current_tenant = Tenant.find_by(subdomain: subdomain_in_url)

    # 2. Skip for root path and authentication processes
    return if is_root_path? || is_auth_process?

    # 3. Handle cases where the tenant room does not exist
    if @current_tenant.nil?
      redirect_to root_path, alert: "Coach not found." and return
    end

    # 4. Permission check and deadlock prevention
    if logged_in?
      # Normalize variable names
      my_subdomain = current_user.tenant.subdomain.to_s.strip
      
      # Redirect only if the current URL subdomain doesn't match the user's assigned subdomain
      if subdomain_in_url != my_subdomain
        # Use string interpolation to ensure the redirect path is 100% accurate
        target_path = "/#{my_subdomain}"
        
        redirect_to target_path, 
                    alert: "Access denied: Redirecting to your room.", 
                    status: :see_other and return
      end
    end
  end

  # Add helper methods to ensure login/logout flows are not intercepted by set_current_tenant
  def is_auth_process?
    controller_name.in?(%w[sessions registrations])
  end

  # 3. Helpers
  def current_tenant
    @current_tenant
  end

  def is_root_path?
    request.path == "/"
  end
end