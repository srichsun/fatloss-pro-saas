class FlashCampaignsController < ApplicationController
  before_action :authenticate_user! # Ensure only logged-in coaches can access

  def index
    # Only show campaigns belonging to the current coach (tenant)
    @flash_campaigns = current_user.tenant.flash_campaigns.order(created_at: :desc)
  end

  def show
    # Scoped via tenant to prevent IDOR — a tenant cannot view another tenant's campaign
    @flash_campaign = current_user.tenant.flash_campaigns.find(params[:id])
    @recent_orders = @flash_campaign.flash_orders.order(created_at: :desc).limit(20)
  end

  def new
    @flash_campaign = current_user.tenant.flash_campaigns.new
  end

  def create
    @flash_campaign = current_user.tenant.flash_campaigns.new(campaign_params)

    # Sync remaining_stock with total_stock initially
    @flash_campaign.remaining_stock = @flash_campaign.total_stock

    if @flash_campaign.save
      redirect_to flash_campaigns_path, notice: "活動建立成功"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def campaign_params
    params.require(:flash_campaign).permit(:title, :price, :total_stock, :expired_at, :product_image)
  end
end
