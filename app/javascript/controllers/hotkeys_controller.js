import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search"]

  connect() {
    // Bind global keyboard shortcuts
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown)
  }

  handleKeydown(event) {
    // Don't trigger if user is typing in an input/textarea
    const isTyping = ['INPUT', 'TEXTAREA'].includes(event.target.tagName)

    // Handle slash key for search focus
    if (event.key === '/' && !isTyping) {
      event.preventDefault()
      this.focusSearch()
      return
    }

    // Don't trigger other shortcuts if user is typing
    if (isTyping) return

    // Get shell controller to handle navigation
    const shellController = this.element.querySelector('[data-controller~="shell"]')
    if (!shellController) return

    const shell = this.application.getControllerForElementAndIdentifier(shellController, 'shell')
    if (!shell) return

    switch(event.key.toLowerCase()) {
      case 't':
        event.preventDefault()
        shell.navigateToPanel('tables')
        break
      case 'p':
        event.preventDefault()
        shell.navigateToPanel('consoles')
        break
      case 'g':
        event.preventDefault()
        shell.navigateToPanel('goods')
        break
      case 'r':
        event.preventDefault()
        shell.navigateToPanel('reservations')
        break
    }
  }

  focusSearch() {
    if (this.hasSearchTarget) {
      this.searchTarget.focus()
      this.searchTarget.select()
    }
  }
}