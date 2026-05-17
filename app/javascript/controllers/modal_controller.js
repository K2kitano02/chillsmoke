import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "panel"]

  open() {
    this.overlayTarget.classList.remove("hidden")
    this.overlayTarget.classList.add("flex")
    this.panelTarget.scrollTop = 0
    document.documentElement.classList.add("overflow-hidden")
  }

  close() {
    this.overlayTarget.classList.add("hidden")
    this.overlayTarget.classList.remove("flex")
    document.documentElement.classList.remove("overflow-hidden")
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && !this.overlayTarget.classList.contains("hidden")) {
      this.close()
    }
  }

  closeFromBackdrop(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }
}
