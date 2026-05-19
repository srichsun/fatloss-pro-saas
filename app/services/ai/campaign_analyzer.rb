require "anthropic"

module Ai
  # Feeds a single flash-sale campaign's aggregate stats to Claude and asks
  # for 3 short actionable insights in Traditional Chinese. The caller
  # renders the returned text — it's not stored.
  class CampaignAnalyzer
    MODEL        = "claude-haiku-4-5"
    MAX_TOKENS   = 600
    MAX_ATTEMPTS = 3

    # Upstream errors that are usually transient (overloaded, rate limit,
    # network blip, timeout). We match by class name string so missing
    # constants in older gem versions don't blow up at load time.
    RETRIABLE_CLASSES = %w[
      Anthropic::Errors::InternalServerError
      Anthropic::Errors::RateLimitError
      Anthropic::Errors::APIConnectionError
      Anthropic::Errors::APITimeoutError
    ].freeze

    Result = Struct.new(:ok?, :insights, :error, keyword_init: true)

    def initialize(campaign:)
      @campaign = campaign
    end

    def call
      attempt = 0
      begin
        attempt += 1
        response = client.messages.create(
          model: MODEL,
          max_tokens: MAX_TOKENS,
          messages: [ { role: "user", content: prompt } ]
        )
        text = response.content.first.text.to_s.strip
        Result.new(ok?: true, insights: text)
      rescue StandardError => e
        if retriable?(e) && attempt < MAX_ATTEMPTS
          wait = backoff_seconds(attempt)
          Rails.logger.warn(
            "[Ai::CampaignAnalyzer] retry #{attempt}/#{MAX_ATTEMPTS - 1} after #{wait}s: #{e.class} #{e.message.to_s[0..120]}"
          )
          sleep(wait)
          retry
        end

        Rails.logger.error("[Ai::CampaignAnalyzer] #{e.class}: #{e.message}")
        Result.new(ok?: false, error: "AI 服務暫時無法使用，請稍後再試")
      end
    end

    private

    def retriable?(error)
      RETRIABLE_CLASSES.include?(error.class.name)
    end

    # Exponential backoff with jitter: 1±s, 2±s. Capped at MAX_ATTEMPTS-1
    # retries so total wait is small enough for a synchronous user request.
    def backoff_seconds(attempt)
      (2 ** (attempt - 1)) + rand
    end

    def client
      @client ||= Anthropic::Client.new(api_key: ENV.fetch("ANTHROPIC_API_KEY"))
    end

    # Aggregate the campaign + its orders into a compact stat block the
    # prompt can reason over. All values come straight from existing
    # columns — no extra instrumentation.
    def stats
      orders = @campaign.flash_orders
      sold   = @campaign.total_stock - @campaign.remaining_stock
      first  = orders.minimum(:created_at)
      last   = orders.maximum(:created_at)

      duration_min = if first && last && last > first
        ((last - first) / 60.0).round(1)
      else
        0
      end

      hour_distribution = orders.pluck(:created_at)
                                .group_by { |t| t.in_time_zone(Time.zone).strftime("%H") }
                                .transform_values(&:count)
                                .sort.to_h

      {
        title:            @campaign.title,
        price:            @campaign.price,
        total_stock:      @campaign.total_stock,
        sold:             sold,
        remaining:        @campaign.remaining_stock,
        sell_through_pct: (@campaign.total_stock.positive? ? (sold.to_f / @campaign.total_stock * 100).round(1) : 0),
        revenue:          @campaign.price * sold,
        order_count:      orders.count,
        first_order_at:   first,
        last_order_at:    last,
        duration_min:     duration_min,
        avg_per_min:      (duration_min.positive? ? (orders.count / duration_min).round(2) : 0),
        hour_distribution: hour_distribution,
        expired:          @campaign.expired?,
        expires_at:       @campaign.expired_at
      }
    end

    def prompt
      s = stats
      <<~PROMPT
        你是電商營運顧問。下面是一檔限時搶購活動的即時數據，請給活動主辦人 3 條具體 actionable 洞察與建議。

        【活動數據】
        - 商品：#{s[:title]}
        - 售價：NT$#{s[:price]}
        - 總庫存：#{s[:total_stock]}
        - 已售：#{s[:sold]}（售完率 #{s[:sell_through_pct]}%）
        - 剩餘：#{s[:remaining]}
        - 累積營收：NT$#{s[:revenue]}
        - 訂單數：#{s[:order_count]}
        - 第一筆下單：#{s[:first_order_at] || '無'}
        - 最後一筆下單：#{s[:last_order_at] || '無'}
        - 已售期間：#{s[:duration_min]} 分鐘
        - 平均速度：#{s[:avg_per_min]} 筆/分鐘
        - 時段分佈（小時:筆數）：#{s[:hour_distribution].inspect}
        - 活動是否已結束：#{s[:expired] ? 'YES' : 'NO'}
        - 截止時間：#{s[:expires_at]}

        【輸出要求】
        - 必須是繁體中文
        - 3 條 markdown bullet（用 `- ` 開頭）
        - 每條最多 40 字
        - 內容要 **針對這個活動的具體數字** 給建議（不要空話）
        - 可以建議：調整定價、加碼推廣、調整庫存、改活動時段、延長截止時間等具體動作
        - 不要前言、不要結語、不要編號、直接 3 條 bullet

        現在開始：
      PROMPT
    end
  end
end
