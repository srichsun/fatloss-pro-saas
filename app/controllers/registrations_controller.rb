class RegistrationsController < ApplicationController
  skip_before_action :set_current_tenant, only: [ :new, :create ]

  def new
    @tenant = Tenant.new
    @user = User.new
  end

  def create
    # Build first so @tenant / @user survive a failed save for re-rendering.
    @tenant = Tenant.new(tenant_params.merge(
      subdomain: SecureRandom.alphanumeric(8).downcase
    ))
    @user = @tenant.users.build(user_params)

    ActiveRecord::Base.transaction do
      @tenant.save!
      @user.save!
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
