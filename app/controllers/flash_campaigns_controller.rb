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

  def edit
    @flash_campaign = current_user.tenant.flash_campaigns.find(params[:id])
  end

  # Edits price / total_stock / expired_at so the influencer can react to
  # AI suggestions like "加碼庫存" or "下次降價試試". When total_stock changes,
  # remaining_stock is adjusted by the diff so the "already sold" count
  # stays correct. The DB check_constraint prevents remaining_stock < 0.
  def update
    @flash_campaign = current_user.tenant.flash_campaigns.find(params[:id])

    new_total = campaign_params[:total_stock].presence&.to_i
    if new_total && new_total != @flash_campaign.total_stock
      diff = new_total - @flash_campaign.total_stock
      @flash_campaign.remaining_stock += diff
    end

    if @flash_campaign.update(campaign_params)
      redirect_to flash_campaign_path(@flash_campaign), notice: "活動已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # AJAX endpoint for the "💡 AI 分析這檔活動" button on the show page.
  # Returns 3 short actionable insights based on current campaign + order stats.
  def analyze
    campaign = current_user.tenant.flash_campaigns.find(params[:id])
    result   = Ai::CampaignAnalyzer.new(campaign: campaign).call

    if result.ok?
      render json: { insights: result.insights }
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  private

  def campaign_params
    params.require(:flash_campaign).permit(:title, :price, :total_stock, :expired_at, :product_image)
  end
end
