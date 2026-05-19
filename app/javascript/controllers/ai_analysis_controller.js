import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai-analysis"
//
// Hits the campaign's analyze endpoint, then renders the returned
// markdown bullets in the result panel. The endpoint is short and
// chunked enough that we don't bother with streaming.
export default class extends Controller {
  static targets = ["button", "result"]
  static values  = { url: String }

  async analyze(event) {
    event.preventDefault()
    this.setBusy(true)
    this.resultTarget.classList.remove("hidden")
    this.resultTarget.innerHTML = `<p class="text-slate-400">分析中…</p>`

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        }
      })
      const payload = await response.json()

      if (response.ok) {
        this.resultTarget.innerHTML = this.renderBullets(payload.insights)
      } else {
        this.resultTarget.innerHTML = `<p class="text-red-600">${payload.error || "分析失敗"}</p>`
      }
    } catch (e) {
      this.resultTarget.innerHTML = `<p class="text-red-600">網路錯誤，請再試一次</p>`
    } finally {
      this.setBusy(false)
    }
  }

  setBusy(busy) {
    this.buttonTarget.disabled = busy
    this.buttonTarget.innerText = busy ? "分析中…" : "分析這檔活動"
  }

  // Minimal markdown bullet renderer — handles "- " / "* " lines and
  // **bold** inline. Anything else is rendered as plain paragraph.
  renderBullets(text) {
    return text
      .split("\n")
      .map(line => line.trim())
      .filter(Boolean)
      .map(line => {
        const stripped = line.replace(/^[-*]\s+/, "")
        const bold = stripped.replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
        if (line.startsWith("-") || line.startsWith("*")) {
          return `<li class="mb-2">${bold}</li>`
        }
        return `<p class="mb-2">${bold}</p>`
      })
      .join("")
      .replace(/(<li[^>]*>.*?<\/li>)+/s, m => `<ul class="list-disc list-inside space-y-1">${m}</ul>`)
  }

  get csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ""
  }
}
