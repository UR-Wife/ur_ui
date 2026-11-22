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

export const UrUiHooks = { UrUiTabs, UrUiAvatarImage }
export default UrUiHooks
