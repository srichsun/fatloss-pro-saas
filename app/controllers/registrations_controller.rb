# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  skip_before_action :set_current_tenant

  def new
    @tenant = Tenant.new
    @user = User.new
  end

  def create
    # Use a Transaction to ensure both Tenant and User are created together
    ActiveRecord::Base.transaction do
      @tenant = Tenant.create!(tenant_params)
      @user = @tenant.users.create!(user_params.merge(role: :coach))
    end
    session[:user_id] = @user.id # Auto-login the user after successful registration
    redirect_to tenant_path(@tenant), notice: "Welcome, Coach!"
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def tenant_params
    params.require(:tenant).permit(:name, :subdomain)
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end