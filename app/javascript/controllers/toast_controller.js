import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    message: String
  }

  connect() {
    // Listen for global error events
    document.addEventListener('app:error', this.handleAppError.bind(this))
    document.addEventListener('turbo:fetch-request-error', this.handleFetchError.bind(this))
  }

  disconnect() {
    document.removeEventListener('app:error', this.handleAppError.bind(this))
    document.removeEventListener('turbo:fetch-request-error', this.handleFetchError.bind(this))
  }

  showSuccess(event) {
    if (event) event.preventDefault()
    this.showToast(this.messageValue || "Success!", 'success')
  }

  showError(event) {
    if (event) event.preventDefault()
    this.showToast(this.messageValue || "An error occurred", 'error')
  }

  error(message) {
    this.showToast(message, 'error')
  }

  info(message) {
    this.showToast(message, 'info')
  }

  retry(label, fn) {
    const toast = this.createToast(label, 'warning')

    // Add retry button
    const retryBtn = document.createElement('button')
    retryBtn.className = 'ml-4 px-3 py-1 bg-yellow-700 hover:bg-yellow-800 rounded text-sm font-medium'
    retryBtn.textContent = 'Retry'
    retryBtn.onclick = () => {
      toast.remove()
      if (fn) fn()
    }

    toast.appendChild(retryBtn)
    this.displayToast(toast)
  }

  handleAppError(event) {
    const { message, retry, event: originalEvent } = event.detail

    if (retry) {
      // Auto-retry once after 2 seconds
      setTimeout(() => {
        this.info('Retrying...')
        // Attempt to reload the frame that had the error
        const frame = originalEvent?.target?.closest('turbo-frame')
        if (frame) {
          frame.reload()
        }
      }, 2000)

      this.error(message)
    } else {
      this.error(message || 'Something went wrong')
    }
  }

  handleFetchError(event) {
    // Don't double-handle if loading controller already caught it
    if (event.defaultPrevented) return

    this.error('Network error. Your actions won\'t be saved.')

    // Show offline indicator
    if (!navigator.onLine) {
      setTimeout(() => {
        this.info('You are offline. Some features may not work.')
      }, 1000)
    }
  }

  showToast(message, type = 'success') {
    const toast = this.createToast(message, type)
    this.displayToast(toast)
  }

  createToast(message, type = 'success') {
    const toast = document.createElement('div')
    const bgColor = {
      'success': 'bg-green-600',
      'error': 'bg-red-600',
      'info': 'bg-blue-600',
      'warning': 'bg-yellow-600'
    }[type] || 'bg-gray-600'

    toast.className = `fixed top-20 right-4 z-50 px-6 py-4 rounded-lg shadow-lg transition-all transform translate-x-full ${bgColor} text-white flex items-center`
    toast.textContent = message

    return toast
  }

  displayToast(toast, duration = 3000) {
    document.body.appendChild(toast)

    // Animate in
    requestAnimationFrame(() => {
      toast.classList.remove('translate-x-full')
      toast.classList.add('translate-x-0')
    })

    // Remove after duration
    setTimeout(() => {
      toast.classList.remove('translate-x-0')
      toast.classList.add('translate-x-full')
      setTimeout(() => toast.remove(), 300)
    }, duration)
  }
}