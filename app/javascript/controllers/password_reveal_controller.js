import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  show(event) {
    event.preventDefault()
    this.inputTarget.type = "text"
  }

  hide() {
    this.inputTarget.type = "password"
  }

  showOnActivation(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.inputTarget.type = "text"
    }
  }

  hideOnEscape(event) {
    if (event.key === "Escape") {
      this.hide()
    }
  }
}
