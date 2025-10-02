import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Restore selection from sessionStorage if exists
    const savedEntityId = sessionStorage.getItem(`selected_${this.element.id}`)
    if (savedEntityId) {
      const card = this.element.querySelector(`[data-entity-id="${savedEntityId}"]`)
      if (card) {
        card.setAttribute('aria-selected', 'true')
      }
    }
  }

  selectCard(event) {
    const card = event.currentTarget
    const entityId = card.dataset.entityId

    // Clear all selections
    this.element.querySelectorAll('[aria-selected]').forEach(el => {
      el.setAttribute('aria-selected', 'false')
    })

    // Set new selection
    card.setAttribute('aria-selected', 'true')

    // Save selection to sessionStorage
    sessionStorage.setItem(`selected_${this.element.id}`, entityId)
  }
}