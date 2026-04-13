
# FlashSale Pro - High-Concurrency Influencer Launchpad

### Status: 🚧 Phase 2: High-Concurrency Core (In Progress)
Current Progress: Successfully implemented Pessimistic Locking and Redis Caching for flash sale scenarios.

### 📖 [Detailed Technical Documentation & Wiki](https://github.com/srichsun/fatloss-pro-saas/wiki)

-----

### 🚀 Project Vision (專案願景)

**Fat Loss Pro** 是一個專為健身網紅打造的「極速快閃銷售」平台。不同於一般的管理系統，本專案針對「萬人瞬間湧入搶購」的場景進行了深度優化，確保在極高併發（High-Concurrency）下，系統依然能保持**庫存精準、反應迅速、穩定不當機**。

---

### 🛠️ Technical Stack (技術選型)

* **Framework**: Rails 8.2 (Edge)
* **High-Concurrency Core**: 
    * **Database**: PostgreSQL with **Pessimistic Locking** (`SELECT ... FOR UPDATE`).
    * **Caching**: **Redis** (Cache-Aside Pattern) for high-speed inventory reads.
    * **Async Jobs**: **Active Job** (Async/Solid Queue) for non-blocking notification delivery.
* **Frontend**: **Hotwire (Turbo/Stimulus)** + **Tailwind CSS** (SPA-like performance).
* **Architecture**: **Multi-tenancy** isolation for scalable B2B2C coaching business.

---

### 🤖 AI-Augmented Development & 10x Velocity (AI 輔助開發與 10 倍速效能)

本專案全面導入 **AI 原生開發工作流 (AI-Native Workflow)**，在確保資深級架構品質的前提下，實現極速交付。

* **10x Efficiency (2 Weeks to 2 Days)**: 
    By leveraging **Cursor Composer** and custom **AI Guardrails**, I successfully condensed a standard **2-week development cycle into just 2 days**.
    (透過整合 AI 輔助工作流，將標準 **2 週的開發週期縮短至僅 2 天**，且不影響系統穩定性。)
* **Architectural Integrity (.cursorrules)**: 
    Used a rigorous `.cursorrules` configuration to enforce **Rails 8 best practices** and **Clean Code** principles, ensuring AI-generated code meets senior engineering standards.
    (透過自定義 `.cursorrules` 規範，確保 AI 產出的程式碼嚴格遵循 Rails 8 最佳實踐與 Clean Code 原則。)
* **AI-Driven Edge Case Testing**: 
    Utilized AI to identify and simulate complex **Race Conditions**, accelerating the TDD process and achieving high test coverage in record time.
    (利用 AI 識別並模擬高併發下的邊際案例與競爭危害，以極短時間達成高測試覆蓋率。)

> *"My core competitive advantage is maintaining **senior-level architectural precision** at **startup-level execution speed** through AI orchestration."*
> (*「我的核心競爭優勢在於：透過 AI 協調，在保持資深級架構精準度的同時，擁有新創等級的執行速度。」*)

-----

### 🛡️ High-Concurrency Highlights (高併發技術亮點)

#### 1. Zero-Overselling Logic (防超賣機制)
在高併發下，最怕「10 個名額賣給 11 個人」。

「我利用資料庫事務（Transaction）來確保『讀取庫存 + 扣除庫存 + 建立訂單』這一組動作的完整性。
同時，我配合使用悲觀鎖（Pessimistic Locking / `@campaign.lock!`）來防止 Race Condition（競態條件），確保在極短時間內湧入的併發請求，不會導致超賣。」

- **Pessimistic Locking**：透過 `@campaign.lock!` 實作資料庫列級鎖定（Row-Level Lock），確保「讀取庫存 + 扣除庫存」這組動作的隔離性（Isolation），防止 Race Condition。
- **Transaction Integrity**：結合資料庫事務，確保「扣庫存」與「訂單建立」若有一方失敗則全數回滾，保證動作的原子性 (Atomicity)。


#### 2. Redis Performance Optimization (效能優化)
為了保護資料庫不被瞬間讀取流量沖垮：
* **Cache-Aside Pattern**: 將剩餘庫存同步至 Redis 記憶體快取。
* **Result**: 讀取庫存的反應速度從毫秒級降至微秒級，大幅降低資料庫 I/O 負擔。


#### 3. Non-blocking Notification (響應式解耦)
下單後的收尾工作不應卡住使用者。
* **Asynchronous Processing**: 透過 `deliver_later` 將 Email 通知交由背景任務處理。
* **Responsiveness**: 確保下單主流程在 100ms 內完成回應，提升使用者體驗。

-----

### 📈 Roadmap (開發進度)

#### **Phase 1: SaaS Foundation (Completed)**
- [x] **Multi-tenant Architecture**: Tenant/User isolation walls.
- [x] **Custom Auth System**: Lightweight session-based logic.

#### **Phase 2: High-Concurrency Flash Sale (Completed)**
- [x] **Inventory Locking**: Implementation of `SELECT FOR UPDATE` logic.
- [x] **Redis Cache Layer**: High-speed stock reading strategy.
- [x] **Async Emailer**: Decoupled order confirmation workflow.

#### **Phase 3: Financial & Scaling (Planning)**
- [ ] **Stripe Integration**: Automated payment with Webhook idempotency.
- [ ] **Real-time Counter**: Live stock updates using **Turbo Streams** over WebSockets.

-----

### ⚡ Quick Start (快速啟動)

#### 1. Setup Environment
```bash
# Start Redis Service
brew services start redis

# Setup database & Migration
bin/rails db:prepare

# Enable Development Caching
bin/rails dev:cache

# Start all services (Rails + Tailwind + Worker)
bin/dev
```
