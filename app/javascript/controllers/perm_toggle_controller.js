import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  toggle() {
    this.element.classList.toggle("btn--reversed", this.checkboxTarget.checked)
  }
}
