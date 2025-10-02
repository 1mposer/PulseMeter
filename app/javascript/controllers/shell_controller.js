import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["navButton"]

  connect() {
    // Load initial panel if specified in URL
    const urlParams = new URLSearchParams(window.location.search)
    const panel = urlParams.get('panel')
    if (panel) {
      this.setActivePanel(panel)
    }
  }

  loadPanel(event) {
    const button = event.currentTarget
    const panel = button.dataset.panel

    // Load content into main_panel frame
    const frame = document.getElementById("main_panel")
    frame.src = `/ui/${panel}`

    // Update active state
    this.setActivePanel(panel)

    // Update URL without reload
    const url = new URL(window.location)
    url.searchParams.set('panel', panel)
    window.history.pushState({}, '', url)
  }

  setActivePanel(panel) {
    // Clear all active states
    this.navButtonTargets.forEach(btn => {
      if (btn.dataset.panel === panel) {
        btn.setAttribute('aria-current', 'page')
      } else {
        btn.setAttribute('aria-current', 'false')
      }
    })
  }

  // Public method for hotkeys controller to call
  navigateToPanel(panel) {
    const button = this.navButtonTargets.find(btn => btn.dataset.panel === panel)
    if (button) {
      button.click()
    }
  }
}