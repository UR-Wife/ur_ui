// ur_ui LiveView hooks. Import once in your app.js and spread into LiveSocket:
//
//   import {UrUiHooks} from "ur_ui"
//   const liveSocket = new LiveSocket("/live", Socket, {hooks: {...UrUiHooks}})
//
// Plain ES module: no inline script, so it works under a strict
// Content-Security-Policy, on Phoenix 1.7 and 1.8.

// tabs/1: roving focus with automatic activation, as in Radix Tabs. Arrow
// Left/Right move to the previous/next enabled tab (wrapping), Home/End to the
// first/last; the target tab is focused and clicked, and its phx-click JS
// commands select it.
const UrUiTabs = {
  mounted() {
    this.onKeyDown = (event) => {
      const tab = event.target.closest('[role="tab"]')
      if (!tab || tab.parentElement !== this.el) return
      const tabs = Array.from(this.el.children).filter(
        (el) => el.getAttribute("role") === "tab" && !el.disabled
      )
      const index = tabs.indexOf(tab)
      const count = tabs.length
      const next = {
        ArrowRight: (index + 1) % count,
        ArrowLeft: (index - 1 + count) % count,
        Home: 0,
        End: count - 1
      }[event.key]
      if (index < 0 || next === undefined) return
      event.preventDefault()
      tabs[next].focus()
      tabs[next].click()
    }
    this.el.addEventListener("keydown", this.onKeyDown)
  },
  destroyed() {
    this.el.removeEventListener("keydown", this.onKeyDown)
  }
}

// avatar_image/1: as in Radix Avatar, show the image only once it has loaded;
// while it loads, or if it fails, it stays hidden and the fallback (its next
// sibling, hidden by CSS only while a visible image precedes it) shows.
const UrUiAvatarImage = {
  mounted() {
    this.onLoad = () => (this.el.hidden = false)
    this.onError = () => (this.el.hidden = true)
    this.el.addEventListener("load", this.onLoad)
    this.el.addEventListener("error", this.onError)
    this.sync()
  },
  updated() {
    this.sync()
  },
  destroyed() {
    this.el.removeEventListener("load", this.onLoad)
    this.el.removeEventListener("error", this.onError)
  },
  // Only sets visibility; the listeners above handle later load/error.
  sync() {
    this.el.hidden = !(this.el.complete && this.el.naturalWidth > 0)
  }
}

// checkbox/1: as in Radix Checkbox, Enter does not toggle the checkbox (only
// Space does); prevent the native button's Enter click.
const UrUiCheckbox = {
  mounted() {
    this.onKeyDown = (event) => {
      if (event.key === "Enter") event.preventDefault()
    }
    this.el.addEventListener("keydown", this.onKeyDown)
  },
  destroyed() {
    this.el.removeEventListener("keydown", this.onKeyDown)
  }
}

// radio_group/1: roving focus with automatic activation, as in Radix
// RadioGroup. Arrow Up/Left/Down/Right move focus to the previous/next enabled
// radio (wrapping), Home/End to the first/last; the target radio is focused
// and clicked, and its phx-click JS selects it. Enter does not select.
const UrUiRadioGroup = {
  mounted() {
    this.onKeyDown = (event) => {
      const radio = event.target.closest('[data-slot="radio-group-item"]')
      if (!radio || !this.el.contains(radio)) return
      const items = Array.from(this.el.querySelectorAll('[data-slot="radio-group-item"]')).filter(
        (el) => !el.disabled
      )
      const index = items.indexOf(radio)
      if (index < 0) return
      if (event.key === "Enter") {
        event.preventDefault()
        return
      }
      const count = items.length
      const next = {
        ArrowRight: (index + 1) % count,
        ArrowDown: (index + 1) % count,
        ArrowLeft: (index - 1 + count) % count,
        ArrowUp: (index - 1 + count) % count,
        Home: 0,
        End: count - 1
      }[event.key]
      if (next === undefined) return
      event.preventDefault()
      items[next].focus()
      items[next].click()
    }
    this.el.addEventListener("keydown", this.onKeyDown)
  },
  destroyed() {
    this.el.removeEventListener("keydown", this.onKeyDown)
  }
}

// progress/1: as in Radix Progress, position the indicator's fill via the
// translate transform. Done through the CSSOM (el.style) so the markup carries
// no inline style= and works under a strict Content-Security-Policy.
const UrUiProgress = {
  mounted() {
    this.sync()
  },
  updated() {
    this.sync()
  },
  sync() {
    const value = Number(this.el.dataset.value)
    const max = Number(this.el.dataset.max) || 100
    const percent = Number.isFinite(value) ? Math.max(0, Math.min(100, (value / max) * 100)) : 0
    this.el.style.transform = `translateX(-${100 - percent}%)`
  }
}

export const UrUiHooks = { UrUiTabs, UrUiAvatarImage, UrUiCheckbox, UrUiRadioGroup, UrUiProgress }
export default UrUiHooks
