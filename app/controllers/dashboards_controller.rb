class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    if current_user.coach?
      # Coach context: Statistics and Client management
      @clients = current_tenant.users.where(role: :client)
      render :coach_dashboard
    else
      # Client context: Personal order history
      render :client_dashboard
    end
  end
end
