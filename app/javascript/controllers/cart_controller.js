import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["itemsList", "emptyMessage", "subtotal", "vat", "total"]
  static values = { entityKey: String }

  connect() {
    // Load cart from sessionStorage
    this.storageKey = `cart:${this.entityKeyValue || 'general'}`
    this.cart = this.loadCart()

    // Listen for cart events
    this.element.addEventListener('cart:add', (event) => {
      this.addToCart(event.detail)
    })

    // Set up keyboard shortcuts
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.handleKeydown)

    // Initial render
    this.renderCart()
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown)
  }

  loadCart() {
    try {
      const stored = sessionStorage.getItem(this.storageKey)
      return stored ? JSON.parse(stored) : {}
    } catch {
      return {}
    }
  }

  saveCart() {
    sessionStorage.setItem(this.storageKey, JSON.stringify(this.cart))
  }

  addToCart(item) {
    const id = item.id

    if (this.cart[id]) {
      this.cart[id].qty += 1
    } else {
      this.cart[id] = {
        name: item.name,
        price: item.price,
        qty: 1
      }
    }

    this.saveCart()
    this.renderCart()
  }

  removeFromCart(id, qty = 1) {
    if (!this.cart[id]) return

    this.cart[id].qty -= qty
    if (this.cart[id].qty <= 0) {
      delete this.cart[id]
    }

    this.saveCart()
    this.renderCart()
  }

  clearCart() {
    this.cart = {}
    this.saveCart()
    this.renderCart()
  }

  renderCart() {
    const items = Object.entries(this.cart)

    if (items.length === 0) {
      this.itemsListTarget.innerHTML = `
        <div class="text-center text-gray-500 py-8">
          Cart is empty
        </div>
      `
    } else {
      this.itemsListTarget.innerHTML = items.map(([id, item]) => `
        <div class="mb-3 pb-3 border-b border-gray-700 last:border-0" data-item-id="${id}">
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <div class="text-white font-medium">${item.name}</div>
              <div class="text-sm text-gray-400">AED ${this.formatCurrency(item.price)} × ${item.qty}</div>
            </div>
            <div class="text-right">
              <div class="text-white font-medium">AED ${this.formatCurrency(item.price * item.qty)}</div>
              <div class="flex gap-1 mt-1">
                <button
                  onclick="this.closest('[data-controller~=cart]').dispatchEvent(new CustomEvent('cart:decrease', {detail: '${id}'}))"
                  class="px-2 py-1 bg-gray-700 hover:bg-gray-600 rounded text-xs text-white"
                >-</button>
                <button
                  onclick="this.closest('[data-controller~=cart]').dispatchEvent(new CustomEvent('cart:add', {detail: {id: '${id}', name: '${item.name}', price: ${item.price}}}))"
                  class="px-2 py-1 bg-gray-700 hover:bg-gray-600 rounded text-xs text-white"
                >+</button>
                <button
                  onclick="this.closest('[data-controller~=cart]').dispatchEvent(new CustomEvent('cart:remove', {detail: '${id}'}))"
                  class="px-2 py-1 bg-red-700 hover:bg-red-600 rounded text-xs text-white"
                >×</button>
              </div>
            </div>
          </div>
        </div>
      `).join('')

      // Add event listeners for the dynamic buttons
      this.element.addEventListener('cart:decrease', (e) => {
        this.removeFromCart(e.detail, 1)
      })
      this.element.addEventListener('cart:remove', (e) => {
        delete this.cart[e.detail]
        this.saveCart()
        this.renderCart()
      })
    }

    // Calculate totals
    const subtotal = items.reduce((sum, [_, item]) => sum + (item.price * item.qty), 0)
    const vat = Math.round(subtotal * 0.05 * 100) / 100  // 5% VAT, rounded to 2 decimals
    const total = subtotal + vat

    // Update totals display
    this.subtotalTarget.textContent = `AED ${this.formatCurrency(subtotal)}`
    this.vatTarget.textContent = `AED ${this.formatCurrency(vat)}`
    this.totalTarget.textContent = `AED ${this.formatCurrency(total)}`
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat('en-AE', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount)
  }

  checkout(event) {
    event.preventDefault()

    if (Object.keys(this.cart).length === 0) {
      this.showToast('Cart is empty', 'error')
      return
    }

    // Calculate final totals for display
    const items = Object.entries(this.cart)
    const subtotal = items.reduce((sum, [_, item]) => sum + (item.price * item.qty), 0)
    const vat = Math.round(subtotal * 0.05 * 100) / 100
    const total = subtotal + vat

    // Show success message
    this.showToast(`Order saved! Total: AED ${this.formatCurrency(total)} (UI stub only)`, 'success')

    // Clear cart after checkout
    this.clearCart()
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

    switch(event.key) {
      case 'Enter':
        event.preventDefault()
        this.checkout(event)
        break

      case '-':
      case '_':
        event.preventDefault()
        // Remove one from last added item
        const lastItem = Object.keys(this.cart).pop()
        if (lastItem) {
          this.removeFromCart(lastItem, 1)
        }
        break

      case 'Backspace':
        if (!event.target.closest('[contenteditable]')) {
          event.preventDefault()
          // Remove selected item or last item
          const lastItem = Object.keys(this.cart).pop()
          if (lastItem) {
            this.removeFromCart(lastItem, 1)
          }
        }
        break
    }
  }
}