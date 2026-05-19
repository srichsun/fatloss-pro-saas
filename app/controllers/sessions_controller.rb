class SessionsController < ApplicationController
  # Allow accessing the login page without being logged in
  skip_before_action :set_current_tenant, only: [ :new, :create, :destroy ]

  def new
    # Render login form
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password]) # # Securely verify password only if the user exists (prevents NoMethodError if user is nil)
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "登入成功"
    else
      flash.now[:alert] = "電子郵件或密碼錯誤"
      render :new, status: :unauthorized
    end
  end

  def destroy
    # 1. Clear the entire session
    reset_session

    # 2. Support both traditional navigation (HTML) and modern Turbo requests
    respond_to do |format|
      # Traditional redirect for standard browser requests
      format.html { redirect_to root_path, notice: "已登出", status: :see_other }

      # Ensure Turbo handles the redirect correctly after a non-GET request (like DELETE)
      format.turbo_stream { redirect_to root_path, notice: "已登出", status: :see_other }
    end
  end
end
