# Fat Loss Pro - B2B2C Coaching SaaS

Status: 🚧 Work In Progress。

### 🚀 專案願景 (Project Vision)
Fat Loss Pro 是一個專為「健身教練與個人工作室」打造的訂閱制管理平台。採用 **B2B2C (Business-to-Business-to-Consumer)** 架構，讓教練能擁有獨立的數位教室，向學員銷售減脂課程並追蹤健康數據。

### 🛠️ 技術選型與核心理念 (Technical Stack & Philosophy)
本專案採用 **Rails 8 (Main Branch)** 架構，專注於「極簡基礎設施、高性能、高安全性」。

* **Rails 8 "Postgres-only" Stack**: 採用 `Solid Queue` 與 `Solid Cache`，移除對 Redis 的依賴，降低運維複雜度。
* **Multi-tenancy Isolation**: 透過 `tenant_id` 與 Controller Scoping 實作物理級資料隔離，杜絕 **IDOR (Insecure Direct Object Reference)** 漏洞。
* **Domain Driven Design (DDD) Patterns**: 核心業務邏輯封裝於 `Service Objects` 與 `Form Objects`，保持 Controller 輕量化且易於測試。
* **Modern Frontend**: 結合 **Tailwind CSS** 與 **Hotwire (Turbo/Stimulus)**，提供 SPA 等級的流暢體驗，同時保持後端渲染的高開發效率。

---

### 📈 開發進度 (Roadmap)

#### **Phase 1: SaaS Foundation (Completed)**
- [x] **Multi-tenant Architecture**: 實作 `Tenant` 與 `User` 的關聯與資料隔離牆。
- [x] **Security Scoping**: 在 `ApplicationController` 強制執行租戶檢查。
- [x] **Automated Testing**: 撰寫 RSpec Request Specs 驗證隔離邏輯。

#### **Phase 2: Financial Integrity (In Progress)**
- [ ] **Service Object Implementation**: 封裝 `Orders::PlaceOrderService` 處理交易原子性。
- [ ] **Precision Currency Handling**: 採用 Rails 5 `Attributes API` 確保金融金額運算精確度。
- [ ] **Idempotency**: 實作冪等性機制，防止重複扣款。

#### **Phase 3: Real-time Data & Performance**
- [ ] **Health Dashboard**: 利用 Turbo Streams 實作無刷新體重追蹤圖表。
- [ ] **Performance Optimization**: 導入 Counter Caches 與 DB Indexing 解決效能瓶頸。

---

### 🛡️ 安全性設計說明 (Security by Design)
在 B2B2C 系統中，資料隱私是第一優先。本專案透過以下方式確保安全：
1.  **Scope-based Querying**: 所有的資料查詢皆從 `current_tenant` 出發，例如：`current_tenant.orders.find(params[:id])`。
2.  **Automated Security Tests**: 每一項核心功能皆附帶 RSpec 測試，模擬跨租戶訪問攻擊，確保隔離邏輯永不失效。

---

### ⚡ 快速啟動 (Quick Start)
```bash
# Clone the repository
git clone [your-repo-link]

# Install dependencies
bundle install
yarn install

# Setup database
bin/rails db:prepare

# Start the development server (Rails 8 default)
bin/dev
```

---

### 🧪 執行測試 (Running Tests)
我們重視代碼品質，請執行以下指令驗證架構安全性：
```bash
bundle exec rspec
```

---
