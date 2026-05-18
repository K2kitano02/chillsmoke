import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  open(event) {
    const overlay = this.findOverlay(event.params.name)

    if (!overlay) return

    this.closeAll()
    overlay.classList.remove("hidden")
    overlay.classList.add("flex")
    overlay.querySelector("[data-modal-panel]")?.scrollTo({ top: 0 })
    document.documentElement.classList.add("overflow-hidden")
  }

  close(event) {
    const overlay = event.target.closest("[data-modal-target~='overlay']")

    if (overlay) {
      this.closeOverlay(overlay)
      this.unlockScrollIfAllClosed()
    } else {
      this.closeAll()
    }
  }

  closeAll() {
    this.overlayTargets.forEach((overlay) => this.closeOverlay(overlay))
    document.documentElement.classList.remove("overflow-hidden")
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.closeAll()
    }
  }

  closeFromBackdrop(event) {
    if (this.overlayTargets.includes(event.target)) {
      this.closeOverlay(event.target)
      this.unlockScrollIfAllClosed()
    }
  }

  findOverlay(name) {
    return this.overlayTargets.find((overlay) => overlay.dataset.modalName === name)
  }

  closeOverlay(overlay) {
    overlay.classList.add("hidden")
    overlay.classList.remove("flex")
  }

  unlockScrollIfAllClosed() {
    if (this.overlayTargets.every((overlay) => overlay.classList.contains("hidden"))) {
      document.documentElement.classList.remove("overflow-hidden")
    }
  }
}
