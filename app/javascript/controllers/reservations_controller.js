import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Track selected reservation
    this.selectedId = null
    this.selectedStatus = null
    this.selectedType = null // 'table' or 'reservation'

    // Set up keyboard shortcuts
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown)
  }

  selectAvailableTable(event) {
    const tableId = event.currentTarget.dataset.tableId
    this.selectedType = 'table'
    this.selectedId = tableId
    this.updateSelection()
  }

  selectReservation(event) {
    const reservationId = event.currentTarget.dataset.reservationId
    const status = event.currentTarget.dataset.reservationStatus

    // Update selection
    this.selectedType = 'reservation'
    this.selectedId = reservationId
    this.selectedStatus = status

    // Clear all other selections
    this.element.querySelectorAll('[aria-selected]').forEach(el => {
      el.setAttribute('aria-selected', 'false')
    })

    // Set this card as selected
    event.currentTarget.setAttribute('aria-selected', 'true')

    // Update action bar
    this.updateSelection()
  }

  quickAction(event) {
    // Double-click handler for smart actions
    event.preventDefault()
    const status = event.currentTarget.dataset.reservationStatus

    if (status === 'reserved') {
      this.checkIn()
    } else if (status === 'seated') {
      this.endReservation()
    }
  }

  updateSelection() {
    // Update data attributes on main element
    this.element.dataset.selectedId = this.selectedId || ''
    this.element.dataset.selectedStatus = this.selectedStatus || ''
    this.element.dataset.selectedType = this.selectedType || ''

    // Dispatch event for action bar to update
    this.element.dispatchEvent(new CustomEvent('reservation:selected', {
      detail: {
        id: this.selectedId,
        status: this.selectedStatus,
        type: this.selectedType
      },
      bubbles: true
    }))
  }

  checkIn() {
    if (this.selectedStatus !== 'reserved') return
    this.showToast('Guest checked in (UI stub)', 'success')
    // Would reload the frames after real action
  }

  endReservation() {
    if (this.selectedStatus !== 'seated') return
    this.showToast('Reservation ended (UI stub)', 'success')
    // Would reload the frames after real action
  }

  showToast(message, type = 'success') {
    const toast = document.createElement('div')
    toast.className = `fixed top-20 right-4 z-50 px-6 py-4 rounded-lg shadow-lg transition-all transform translate-x-full ${
      type === 'success' ? 'bg-green-600 text-white' : 'bg-red-600 text-white'
    }`
    toast.textContent = message

    document.body.appendChild(toast)

    requestAnimationFrame(() => {
      toast.classList.remove('translate-x-full')
      toast.classList.add('translate-x-0')
    })

    setTimeout(() => {
      toast.classList.remove('translate-x-0')
      toast.classList.add('translate-x-full')
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }

  handleKeydown(event) {
    // Don't trigger if user is typing in an input
    if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') return

    // Get action bar controller
    const actionBar = document.querySelector('[data-controller~="action-bar"]')
    const actionBarController = actionBar ?
      this.application.getControllerForElementAndIdentifier(actionBar, 'action-bar') : null

    switch(event.key.toLowerCase()) {
      case 'n':
        event.preventDefault()
        if (actionBarController) actionBarController.newReservation()
        break

      case 'i':
        event.preventDefault()
        if (this.selectedStatus === 'reserved') this.checkIn()
        break

      case 'e':
        event.preventDefault()
        if (this.selectedStatus === 'seated') this.endReservation()
        break

      case '+':
      case '=':
        event.preventDefault()
        if (actionBarController) actionBarController.extend()
        break

      case 'x':
        event.preventDefault()
        if (actionBarController) actionBarController.cancel()
        break

      case 'm':
        event.preventDefault()
        if (actionBarController) actionBarController.move()
        break
    }
  }
}