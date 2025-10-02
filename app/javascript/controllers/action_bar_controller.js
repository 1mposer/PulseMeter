import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "newBtn", "checkInBtn", "endBtn", "extendBtn",
    "moveBtn", "cancelBtn", "noShowBtn"
  ]

  connect() {
    // Listen for selection changes
    this.element.addEventListener('reservation:selected', (event) => {
      this.updateButtons(event.detail)
    })

    // Get parent controller data if exists
    const parent = this.element.closest('[data-controller~="reservations"]')
    if (parent) {
      const selectedId = parent.dataset.selectedId
      const selectedStatus = parent.dataset.selectedStatus
      const selectedType = parent.dataset.selectedType

      if (selectedId) {
        this.updateButtons({ id: selectedId, status: selectedStatus, type: selectedType })
      }
    }
  }

  updateButtons(selection) {
    const { id, status, type } = selection

    // Reset all buttons
    this.disableAll()

    if (!id) return

    if (type === 'reservation') {
      // Enable buttons based on reservation status
      if (status === 'reserved') {
        this.enableButton(this.checkInBtnTarget)
        this.enableButton(this.cancelBtnTarget)
        this.enableButton(this.noShowBtnTarget)
      } else if (status === 'seated') {
        this.enableButton(this.endBtnTarget)
        this.enableButton(this.extendBtnTarget)
        this.enableButton(this.moveBtnTarget)
      }
    }
  }

  disableAll() {
    [
      this.checkInBtnTarget, this.endBtnTarget, this.extendBtnTarget,
      this.moveBtnTarget, this.cancelBtnTarget, this.noShowBtnTarget
    ].forEach(btn => this.disableButton(btn))
  }

  enableButton(button) {
    button.disabled = false
    button.classList.remove('bg-gray-700', 'text-gray-400')
    button.classList.add('bg-gray-600', 'text-white', 'hover:bg-gray-500')
  }

  disableButton(button) {
    button.disabled = true
    button.classList.remove('bg-gray-600', 'text-white', 'hover:bg-gray-500')
    button.classList.add('bg-gray-700', 'text-gray-400')
  }

  newReservation() {
    // Load new reservation form in drawer
    const drawer = document.getElementById('reservations_drawer')
    if (drawer) {
      drawer.src = '/reservations/new'
    }
  }

  checkIn() {
    this.performAction('Checked in (UI stub)', 'check_in')
  }

  end() {
    this.performAction('Reservation ended (UI stub)', 'end')
  }

  extend() {
    // Simulate conflict check
    if (Math.random() < 0.3) {
      this.showToast('Conflict at 17:00. Try +5 or Move to T6.', 'error')
    } else {
      this.performAction('Extended by 15 minutes (UI stub)', 'extend')
    }
  }

  move() {
    this.showToast('Move feature coming soon (drag & drop)', 'info')
  }

  cancel() {
    this.performAction('Reservation cancelled (UI stub)', 'cancel')
  }

  noShow() {
    this.performAction('Marked as no-show (UI stub)', 'no_show')
  }

  performAction(message, action) {
    // Get selected ID from parent controller
    const parent = this.element.closest('[data-controller~="reservations"]')
    const selectedId = parent?.dataset.selectedId

    if (!selectedId) return

    this.showToast(message, 'success')

    // In real app, would POST to the action endpoint and reload frames
    // For now, just refresh the active list
    const rightFrame = document.getElementById('reservations_right')
    if (rightFrame) {
      rightFrame.reload()
    }
  }

  showToast(message, type = 'success') {
    const toast = document.createElement('div')
    const bgColor = type === 'error' ? 'bg-red-600' :
                    type === 'info' ? 'bg-blue-600' : 'bg-green-600'

    toast.className = `fixed top-20 right-4 z-50 px-6 py-4 rounded-lg shadow-lg transition-all transform translate-x-full ${bgColor} text-white`
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
}