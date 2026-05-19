class RegistrationsController < ApplicationController
  skip_before_action :set_current_tenant, only: [ :new, :create ]

  def new
    @tenant = Tenant.new
    @user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
      @tenant = Tenant.create!(tenant_params.merge(
        subdomain: SecureRandom.alphanumeric(8).downcase
      ))
      @user = @tenant.users.create!(user_params)
    end
    session[:user_id] = @user.id
    redirect_to dashboard_path, notice: "Welcome!"
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

  def tenant_params
    params.require(:tenant).permit(:name)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
