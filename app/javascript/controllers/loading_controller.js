import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Add loading state on fetch start
    this.element.addEventListener('turbo:before-fetch-request', this.showLoading.bind(this))

    // Remove loading state on frame load
    this.element.addEventListener('turbo:frame-load', this.hideLoading.bind(this))
    this.element.addEventListener('turbo:frame-render', this.hideLoading.bind(this))

    // Handle errors
    this.element.addEventListener('turbo:fetch-request-error', this.handleError.bind(this))
  }

  showLoading() {
    this.element.classList.add('is-loading')

    // Add skeleton loader if frame is empty or has little content
    if (this.element.children.length === 0 || this.element.textContent.trim().length < 50) {
      this.addSkeleton()
    }
  }

  hideLoading() {
    this.element.classList.remove('is-loading')
    this.removeSkeleton()
  }

  addSkeleton() {
    // Don't add skeleton if one already exists
    if (this.element.querySelector('.skeleton-loader')) return

    const skeleton = document.createElement('div')
    skeleton.className = 'skeleton-loader p-8'
    skeleton.innerHTML = `
      <div class="animate-pulse space-y-4">
        <div class="h-4 bg-gray-700 rounded w-3/4"></div>
        <div class="h-4 bg-gray-700 rounded w-1/2"></div>
        <div class="space-y-2">
          <div class="h-3 bg-gray-700 rounded"></div>
          <div class="h-3 bg-gray-700 rounded"></div>
          <div class="h-3 bg-gray-700 rounded w-5/6"></div>
        </div>
      </div>
    `
    this.element.appendChild(skeleton)
  }

  removeSkeleton() {
    const skeleton = this.element.querySelector('.skeleton-loader')
    if (skeleton) {
      skeleton.remove()
    }
  }

  handleError(event) {
    this.hideLoading()

    // Dispatch error event for toast controller to handle
    document.dispatchEvent(new CustomEvent('app:error', {
      detail: {
        message: 'Network hiccup. Retrying...',
        retry: true,
        event: event
      }
    }))
  }
}