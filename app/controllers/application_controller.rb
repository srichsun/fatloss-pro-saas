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

  def current_tenant
    # [INTERVIEW POINT: Multi-tenancy Strategy]
    # Derive tenant from authenticated session to ensure strict data isolation.
    @current_tenant ||= current_user&.tenant
  end

  def logged_in?
    current_user.present?
  end

  # Use this in sub-controllers (e.g., Dashboards) to force login
  def authenticate_user!
    unless logged_in?
      # Store the intended URL to redirect back after login (Standard UX)
      session[:return_to] = request.fullpath
      redirect_to login_path, alert: "Please sign in to continue."
    end
  end

  # 2. Tenant Scoping & Security Logic (Identity-Based Strategy)
  def set_current_tenant
    # [POINT: Multi-tenancy Isolation]
    # We've moved away from URL-based (subdomain) identification to Identity-based.
    # The tenant context is strictly derived from the authenticated user.
    if logged_in?
      @current_tenant = current_user.tenant
    else
      # For public pages or login process, @current_tenant remains nil
      @current_tenant = nil
    end
  end

end
