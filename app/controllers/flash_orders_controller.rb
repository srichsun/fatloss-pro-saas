class FlashOrdersController < ApplicationController
  # This controller handles high-concurrency grab requests from fans

  def create
    @campaign = FlashCampaign.find(params[:campaign_sale_id])

    # Reject expired campaigns early to skip an unnecessary lock acquisition.
    if @campaign.expired?
      redirect_to campaign_sale_path(@campaign), alert: "此搶購活動已結束"
      return
    end

    # 1. Open a transaction to ensure all database operations are atomic
    FlashOrder.transaction do
      # 2. Pessimistic Locking: SELECT ... FOR UPDATE
      # This locks the row so no other request can modify the stock simultaneously
      @campaign.lock!

      if @campaign.remaining_stock > 0
        @order = @campaign.flash_orders.new(order_params)

        if @order.save
          # 3. Decrement stock directly within the same lock
          @campaign.update!(remaining_stock: @campaign.remaining_stock - 1)

          # Use deliver_later to send email in background (Asynchronous)
          OrderMailer.confirmation_email(@order).deliver_later

          redirect_to campaign_sale_path(@campaign), notice: "搶購成功！"
        else
          # If form validation fails, redirect back with error messages
          redirect_to campaign_sale_path(@campaign), alert: @order.errors.full_messages.join(", ")
          raise ActiveRecord::Rollback
        end
      else
        # 4. Handle Out of Stock scenario
        redirect_to campaign_sale_path(@campaign), alert: "很抱歉，商品已售完"
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "找不到此活動"
  rescue => e
    logger.error "Flash Order Failure: #{e.message}"
    redirect_to campaign_sale_path(@campaign), alert: "發生錯誤，請稍後再試"
  end

  private

  def order_params
    params.require(:flash_order).permit(:name, :email, :phone)
  end
end
