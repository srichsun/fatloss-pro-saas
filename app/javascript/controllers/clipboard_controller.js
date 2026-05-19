import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
//
// Usage:
//   <div data-controller="clipboard">
//     <span data-clipboard-target="source">text to copy</span>
//     <button data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
//   </div>
export default class extends Controller {
  static targets = ["source", "button"]

  async copy(event) {
    event.preventDefault()
    const text = this.sourceTarget.innerText.trim()

    try {
      await navigator.clipboard.writeText(text)
      this.flash("Copied!")
    } catch {
      this.flash("Press Cmd+C")
    }
  }

  flash(message) {
    if (!this.hasButtonTarget) return
    const original = this.buttonTarget.innerText
    this.buttonTarget.innerText = message
    setTimeout(() => { this.buttonTarget.innerText = original }, 1500)
  }
}
