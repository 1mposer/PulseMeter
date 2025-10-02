import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categoryBtn", "itemBtn", "itemsGrid"]

  connect() {
    // Set up keyboard shortcuts
    this.handleKeypress = this.handleKeypress.bind(this)
    document.addEventListener('keypress', this.handleKeypress)

    // Show first category by default
    this.currentCategory = "drinks"
  }

  disconnect() {
    document.removeEventListener('keypress', this.handleKeypress)
  }

  filterCategory(event) {
    const button = event.currentTarget
    const category = button.dataset.category

    // Update active state on category buttons
    this.categoryBtnTargets.forEach(btn => {
      if (btn.dataset.category === category) {
        btn.classList.remove('bg-gray-700', 'hover:bg-gray-600')
        btn.classList.add('bg-blue-600', 'hover:bg-blue-700')
        btn.setAttribute('aria-pressed', 'true')
      } else {
        btn.classList.remove('bg-blue-600', 'hover:bg-blue-700')
        btn.classList.add('bg-gray-700', 'hover:bg-gray-600')
        btn.setAttribute('aria-pressed', 'false')
      }
    })

    // Show/hide items based on category
    this.itemBtnTargets.forEach(item => {
      if (item.dataset.category === category) {
        item.classList.remove('hidden')
        // Update shortcuts for first 9 items of current category
        const visibleItems = this.itemBtnTargets.filter(i =>
          i.dataset.category === category
        )
        visibleItems.forEach((item, index) => {
          if (index < 9) {
            item.dataset.shortcut = index + 1
            // Update or add shortcut indicator
            let shortcutEl = item.querySelector('.shortcut-indicator')
            if (!shortcutEl) {
              shortcutEl = document.createElement('div')
              shortcutEl.className = 'shortcut-indicator absolute top-2 right-2 w-6 h-6 bg-gray-700 rounded flex items-center justify-center text-xs text-gray-400'
              item.appendChild(shortcutEl)
            }
            shortcutEl.textContent = index + 1
          } else {
            item.dataset.shortcut = ''
            const shortcutEl = item.querySelector('.shortcut-indicator')
            if (shortcutEl) shortcutEl.remove()
          }
        })
      } else {
        item.classList.add('hidden')
        item.dataset.shortcut = ''
      }
    })

    this.currentCategory = category
  }

  addItem(event) {
    const button = event.currentTarget
    const item = {
      id: button.dataset.itemId,
      name: button.dataset.itemName,
      price: parseFloat(button.dataset.itemPrice)
    }

    // Dispatch custom event for cart controller
    this.element.dispatchEvent(new CustomEvent('cart:add', {
      detail: item,
      bubbles: true
    }))

    // Visual feedback
    button.classList.add('ring-2', 'ring-green-500')
    setTimeout(() => {
      button.classList.remove('ring-2', 'ring-green-500')
    }, 200)
  }

  handleKeypress(event) {
    // Don't trigger if user is typing in an input
    if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') return

    const key = event.key

    // Number shortcuts 1-9
    if (key >= '1' && key <= '9') {
      event.preventDefault()
      const visibleItems = this.itemBtnTargets.filter(item =>
        !item.classList.contains('hidden') && item.dataset.shortcut === key
      )
      if (visibleItems.length > 0) {
        visibleItems[0].click()
      }
    }
  }
}