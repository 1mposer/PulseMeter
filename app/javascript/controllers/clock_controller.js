import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    now: String // Server time for initial sync
  }
  static targets = ["time", "shift"]

  connect() {
    // Initialize server time offset if provided
    if (this.nowValue) {
      const serverTime = new Date(this.nowValue)
      const clientTime = new Date()
      this.timeOffset = serverTime - clientTime
    } else {
      this.timeOffset = 0
    }

    this.update()
    // Update every 30 seconds for more responsive shift changes
    this.timer = setInterval(() => this.update(), 30000)
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  update() {
    const now = new Date()
    // Apply server time offset for accuracy
    const adjustedTime = new Date(now.getTime() + this.timeOffset)

    // Update time display
    if (this.hasTimeTarget) {
      const options = {
        month: 'short',
        day: 'numeric',
        year: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        hour12: false
      }
      const formatted = new Intl.DateTimeFormat(undefined, options).format(adjustedTime)
      this.timeTarget.textContent = formatted
    }

    // Update shift display if target exists
    if (this.hasShiftTarget) {
      this.shiftTarget.textContent = this.calculateShift(adjustedTime)
    }
  }

  calculateShift(date) {
    const hour = date.getHours()

    // Shift schedule:
    // Shift 1: 06:00 - 14:00 (morning)
    // Shift 2: 14:00 - 22:00 (afternoon)
    // Shift 3: 22:00 - 06:00 (night)
    if (hour >= 6 && hour < 14) {
      return 'Shift 1'
    } else if (hour >= 14 && hour < 22) {
      return 'Shift 2'
    } else {
      return 'Shift 3'
    }
  }
}