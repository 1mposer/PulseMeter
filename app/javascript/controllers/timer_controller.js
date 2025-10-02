import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    startAt: String,
    countdown: Boolean
  }

  connect() {
    this.update()
    // Update every 30 seconds
    this.timer = setInterval(() => this.update(), 30000)
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  update() {
    if (!this.startAtValue) return

    const startTime = new Date(this.startAtValue)
    const now = new Date()

    let diffMs
    if (this.countdownValue) {
      // Countdown mode (for future use in reservations)
      diffMs = startTime - now
      if (diffMs < 0) diffMs = 0
    } else {
      // Elapsed time mode
      diffMs = now - startTime
      if (diffMs < 0) diffMs = 0
    }

    const hours = Math.floor(diffMs / 3600000)
    const minutes = Math.floor((diffMs % 3600000) / 60000)
    const seconds = Math.floor((diffMs % 60000) / 1000)

    const formatted = [
      hours.toString().padStart(2, '0'),
      minutes.toString().padStart(2, '0'),
      seconds.toString().padStart(2, '0')
    ].join(':')

    this.element.textContent = formatted

    // Also update cost estimate if element has data-rate attribute
    const rate = parseFloat(this.element.dataset.rate)
    if (rate) {
      const minutesElapsed = diffMs / 60000
      const cost = (minutesElapsed * rate).toFixed(2)
      const costElement = this.element.closest('.timer-container')?.querySelector('.cost-estimate')
      if (costElement) {
        costElement.textContent = `$${cost}`
      }
    }
  }
}