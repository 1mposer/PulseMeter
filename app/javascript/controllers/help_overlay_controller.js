import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    // Listen for ? key
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.handleKeydown)

    // Create overlay if doesn't exist
    if (!this.hasOverlayTarget) {
      this.createOverlay()
    }
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown)
  }

  handleKeydown(event) {
    // Show on ? (shift+/)
    if (event.key === '?' && !event.target.matches('input, textarea')) {
      event.preventDefault()
      this.toggle()
    }

    // Hide on Esc
    if (event.key === 'Escape' && this.isVisible()) {
      event.preventDefault()
      this.hide()
    }
  }

  createOverlay() {
    const overlay = document.createElement('div')
    overlay.dataset.helpOverlayTarget = 'overlay'
    overlay.className = 'fixed inset-0 z-50 bg-black/80 backdrop-blur-sm hidden flex items-center justify-center p-8'
    overlay.innerHTML = `
      <div class="bg-gray-800 rounded-lg max-w-3xl w-full max-h-[80vh] overflow-y-auto shadow-2xl">
        <div class="p-6 border-b border-gray-700">
          <div class="flex items-center justify-between">
            <h2 class="text-2xl font-bold text-white">Keyboard Shortcuts</h2>
            <button
              data-action="click->help-overlay#hide"
              class="text-gray-400 hover:text-white transition-colors"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          <p class="text-sm text-gray-400 mt-2">Press <kbd class="px-2 py-1 bg-gray-700 rounded text-xs">Esc</kbd> to close</p>
        </div>

        <div class="p-6 space-y-6">
          <!-- Global Shortcuts -->
          <div>
            <h3 class="text-lg font-semibold text-white mb-3">Global Navigation</h3>
            <div class="grid grid-cols-2 gap-3">
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">T</kbd>
                <span class="text-gray-300">Open Tables panel</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">P</kbd>
                <span class="text-gray-300">Open PS/Consoles panel</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">G</kbd>
                <span class="text-gray-300">Open Goods Sale panel</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">R</kbd>
                <span class="text-gray-300">Open Reservations panel</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">/</kbd>
                <span class="text-gray-300">Focus search</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">?</kbd>
                <span class="text-gray-300">Show this help</span>
              </div>
            </div>
          </div>

          <!-- Goods Panel -->
          <div>
            <h3 class="text-lg font-semibold text-white mb-3">Goods Sale</h3>
            <div class="grid grid-cols-2 gap-3">
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">1-9</kbd>
                <span class="text-gray-300">Quick add items</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">Enter</kbd>
                <span class="text-gray-300">Checkout</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">-</kbd>
                <span class="text-gray-300">Remove last item</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">Backspace</kbd>
                <span class="text-gray-300">Remove selected item</span>
              </div>
            </div>
          </div>

          <!-- Reservations Panel -->
          <div>
            <h3 class="text-lg font-semibold text-white mb-3">Reservations</h3>
            <div class="grid grid-cols-2 gap-3">
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">N</kbd>
                <span class="text-gray-300">New reservation</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">I</kbd>
                <span class="text-gray-300">Check-in guest</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">E</kbd>
                <span class="text-gray-300">End session</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">+</kbd>
                <span class="text-gray-300">Extend 15 minutes</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">X</kbd>
                <span class="text-gray-300">Cancel reservation</span>
              </div>
              <div class="flex items-center gap-3">
                <kbd class="px-3 py-1 bg-gray-700 text-white rounded font-mono">M</kbd>
                <span class="text-gray-300">Move to another table</span>
              </div>
            </div>
          </div>

          <!-- Tips -->
          <div class="pt-4 border-t border-gray-700">
            <h3 class="text-lg font-semibold text-white mb-3">Pro Tips</h3>
            <ul class="space-y-2 text-sm text-gray-300">
              <li>• Double-click reservation cards for quick check-in or end</li>
              <li>• Tab through elements and press Enter to activate</li>
              <li>• All panels auto-save to session storage</li>
              <li>• Shift times update automatically based on current time</li>
            </ul>
          </div>
        </div>
      </div>
    `

    // Click overlay background to close
    overlay.addEventListener('click', (event) => {
      if (event.target === overlay) {
        this.hide()
      }
    })

    this.element.appendChild(overlay)
  }

  toggle() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle('hidden')
    }
  }

  show() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove('hidden')
    }
  }

  hide() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add('hidden')
    }
  }

  isVisible() {
    return this.hasOverlayTarget && !this.overlayTarget.classList.contains('hidden')
  }
}