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
// Space does); prevent the native button's Enter click. The checkbox toggles
// client-side, so when it sits inside a <form> the hook also observes that
// form's reset event and restores the button's checked visual and ARIA state —
// and the hidden input — to the initial `checked` value, which a native
// form.reset() would otherwise leave stale.
const UrUiCheckbox = {
  mounted() {
    this.onKeyDown = (event) => {
      if (event.key === "Enter") event.preventDefault()
    }
    this.el.addEventListener("keydown", this.onKeyDown)

    this.form = this.el.closest("form")
    this.onReset = () => this.restore()
    if (this.form) this.form.addEventListener("reset", this.onReset)
    this.snapshot()
  },
  updated() {
    this.snapshot()
  },
  destroyed() {
    this.el.removeEventListener("keydown", this.onKeyDown)
    if (this.form) this.form.removeEventListener("reset", this.onReset)
  },
  // The hidden input (rendered only when `name` is given) is the source of
  // truth for the checkbox's default/initial value.
  inputRef() {
    return document.getElementById(this.el.id + "-input")
  },
  snapshot() {
    const input = this.inputRef()
    this.initialChecked = input
      ? input.defaultChecked
      : this.el.getAttribute("aria-checked") === "true"
  },
  restore() {
    const checked = this.initialChecked
    this.el.setAttribute("aria-checked", checked ? "true" : "false")
    this.el.setAttribute("data-state", checked ? "checked" : "unchecked")
    const indicator = this.el.querySelector("[data-slot=checkbox-indicator]")
    if (indicator) {
      indicator.setAttribute("data-state", checked ? "checked" : "unchecked")
      if (checked) {
        indicator.removeAttribute("hidden")
      } else {
        indicator.setAttribute("hidden", "hidden")
      }
    }
    const input = this.inputRef()
    if (input) {
      input.checked = checked
      input.defaultChecked = checked
    }
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

// slider/1: single-thumb slider as in Radix Slider. Keyboard (Arrow
// Left/Right or Up/Down for vertical move by `step`, Home/End jump to min/max,
// PageUp/PageDown move by 10x step) and pointer (click/track and thumb drag via
// mouse/touch/pen) update the value; all changes snap to `step` relative to
// `min` before being clamped to [min, max]. The range and thumb positions —
// including Radix's "in-bounds" thumb offset — are applied through the CSSOM
// (el.style), so the markup carries no inline style and works under a CSP.
const UrUiSlider = {
  mounted() {
    this.onKeyDown = (event) => {
      const thumb = event.target.closest('[data-slot="slider-thumb"]')
      if (!thumb || !this.el.contains(thumb)) return
      if (this.el.dataset.disabled !== undefined) return

      const horizontal = this.el.dataset.orientation !== "vertical"

      if (event.key === "Home") {
        event.preventDefault()
        this.updateValues(this.min())
      } else if (event.key === "End") {
        event.preventDefault()
        this.updateValues(this.max())
      } else {
        let direction = 0
        let multiplier = 1
        if (event.key === (horizontal ? "ArrowRight" : "ArrowUp")) {
          direction = 1
        } else if (event.key === (horizontal ? "ArrowLeft" : "ArrowDown")) {
          direction = -1
        } else if (event.key === "PageUp") {
          direction = 1
          multiplier = 10
        } else if (event.key === "PageDown") {
          direction = -1
          multiplier = 10
        } else {
          return
        }
        event.preventDefault()
        this.updateValues(this.nextStepValue(this.currentValue(), direction, multiplier))
      }
    }

    this.onPointerDown = (event) => {
      if (this.el.dataset.disabled !== undefined) return
      const target = event.target
      if (target.setPointerCapture) {
        try {
          target.setPointerCapture(event.pointerId)
        } catch (_) {}
      }
      if (event.cancelable) event.preventDefault()
      const thumb = this.thumb()
      if (thumb && target === thumb) {
        thumb.focus({ preventScroll: true, focusVisible: false })
      } else {
        this.slide(event)
      }
    }

    this.onPointerMove = (event) => {
      if (this.el.dataset.disabled !== undefined) return
      const target = event.target
      if (target.hasPointerCapture && target.hasPointerCapture(event.pointerId)) {
        this.slide(event)
      }
    }

    this.onPointerUp = (event) => {
      const target = event.target
      if (target.hasPointerCapture && target.hasPointerCapture(event.pointerId)) {
        if (target.releasePointerCapture) {
          try {
            target.releasePointerCapture(event.pointerId)
          } catch (_) {}
        }
      }
    }

    this.el.addEventListener("keydown", this.onKeyDown)
    this.el.addEventListener("pointerdown", this.onPointerDown)
    this.el.addEventListener("pointermove", this.onPointerMove)
    this.el.addEventListener("pointerup", this.onPointerUp)
    this.el.addEventListener("pointercancel", this.onPointerUp)
    this.sync()
  },
  updated() {
    this.sync()
  },
  destroyed() {
    this.el.removeEventListener("keydown", this.onKeyDown)
    this.el.removeEventListener("pointerdown", this.onPointerDown)
    this.el.removeEventListener("pointermove", this.onPointerMove)
    this.el.removeEventListener("pointerup", this.onPointerUp)
    this.el.removeEventListener("pointercancel", this.onPointerUp)
  },
  min() {
    return Number(this.el.dataset.min ?? 0)
  },
  max() {
    return Number(this.el.dataset.max ?? 100)
  },
  step() {
    return Number(this.el.dataset.step ?? 1)
  },
  thumb() {
    return this.el.querySelector('[data-slot="slider-thumb"]')
  },
  currentValue() {
    return Number(this.el.dataset.value ?? 0)
  },
  setValue(value) {
    this.el.dataset.value = String(value)
    const thumb = this.thumb()
    if (thumb) thumb.setAttribute("aria-valuenow", String(value))
    this.sync()
  },
  // Snap `value` to the nearest multiple of `step` relative to `min`, then
  // clamp to [min, max]. This keeps pointer jumps and keyboard changes on-step
  // even when (max - min) is not divisible by `step`.
  updateValues(value) {
    const min = this.min()
    const max = this.max()
    const step = this.step()
    const decimalCount = this.decimalCount(step)
    const snapped = this.roundValue(Math.round((value - min) / step) * step + min, decimalCount)
    this.setValue(Math.min(max, Math.max(min, snapped)))
  },
  // Radix's getNextStepValue: align the current value to the nearest step
  // before stepping, so ArrowLeft after End (an unaligned max) lands on a valid
  // step rather than `max - step`.
  nextStepValue(value, direction, multiplier) {
    const min = this.min()
    const step = this.step()
    const decimalCount = this.decimalCount(step)
    const stepsFromMin = (value - min) / step
    const nearestSteps = Math.round(stepsFromMin)
    const isAligned =
      this.roundValue(nearestSteps * step + min, decimalCount) ===
      this.roundValue(value, decimalCount)
    let nextSteps
    if (isAligned) {
      nextSteps = nearestSteps + multiplier * direction
    } else if (direction > 0) {
      nextSteps = Math.ceil(stepsFromMin)
    } else {
      nextSteps = Math.floor(stepsFromMin)
    }
    return this.roundValue(nextSteps * step + min, decimalCount)
  },
  slide(event) {
    const rect = this.el.getBoundingClientRect()
    if (this.el.dataset.orientation !== "vertical") {
      this.updateValues(this.linearScale([0, rect.width], [this.min(), this.max()])(event.clientX - rect.left))
    } else {
      this.updateValues(this.linearScale([0, rect.height], [this.max(), this.min()])(event.clientY - rect.top))
    }
  },
  linearScale(input, output) {
    return (value) => {
      if (input[0] === input[1] || output[0] === output[1]) return output[0]
      const ratio = (output[1] - output[0]) / (input[1] - input[0])
      return output[0] + ratio * (value - input[0])
    }
  },
  decimalCount(value) {
    if (!Number.isFinite(value)) return 0
    const str = value.toString()
    if (str.includes("e")) {
      const [coefficient, exponent] = str.split("e")
      const decimalPart = coefficient.split(".")[1] || ""
      return Math.max(0, decimalPart.length - Number(exponent))
    }
    const decimalPart = str.split(".")[1]
    return decimalPart ? decimalPart.length : 0
  },
  roundValue(value, decimalCount) {
    const rounder = Math.pow(10, decimalCount)
    return Math.round(value * rounder) / rounder
  },
  sync() {
    const thumb = this.el.querySelector('[data-slot="slider-thumb"]')
    const range = this.el.querySelector('[data-slot="slider-range"]')
    if (!thumb || !range) return

    const min = Number(this.el.dataset.min ?? 0)
    const max = Number(this.el.dataset.max ?? 100)
    const value = Number(this.el.dataset.value ?? 0)
    const horizontal = this.el.dataset.orientation !== "vertical"
    const ratio = (value - min) / (max - min)
    const percent = Math.min(100, Math.max(0, ratio * 100))

    if (horizontal) {
      range.style.left = "0%"
      range.style.right = `${100 - percent}%`
      range.style.top = ""
      range.style.bottom = ""
    } else {
      range.style.top = `${100 - percent}%`
      range.style.bottom = "0%"
      range.style.left = ""
      range.style.right = ""
    }

    const thumbSize = horizontal ? thumb.offsetWidth : thumb.offsetHeight
    const halfWidth = thumbSize > 0 ? thumbSize / 2 : 8
    // linearScale([0, 50], [0, halfWidth]) without clamping, then the in-bounds
    // offset Radix applies so the thumb never overflows the track.
    const scaled = (halfWidth / 50) * percent
    const offset = halfWidth - scaled

    thumb.style.position = "absolute"
    if (horizontal) {
      thumb.style.transform = "translateX(-50%)"
      thumb.style.left = `calc(${percent}% + ${offset}px)`
      thumb.style.bottom = ""
      thumb.style.top = ""
    } else {
      thumb.style.transform = "translateY(50%)"
      thumb.style.bottom = `calc(${percent}% + ${offset}px)`
      thumb.style.left = ""
      thumb.style.right = ""
    }
  }
}

// toggle_group/1: roving focus as in Radix ToggleGroup. Arrow keys move focus
// to the next/previous enabled item (wrapping), Home/End to the first/last; in
// single mode the focused item is also clicked (selected). Enter is prevented
// in single mode (selection is via Space/click), as in Radix RadioGroup.
const UrUiToggleGroup = {
  mounted() {
    this.onKeyDown = (event) => {
      const item = event.target.closest('[data-slot="toggle-group-item"]')
      if (!item || !this.el.contains(item)) return
      const type = this.el.dataset.type || "single"
      const items = Array.from(this.el.querySelectorAll('[data-slot="toggle-group-item"]')).filter(
        (el) => !el.disabled
      )
      const index = items.indexOf(item)
      if (index < 0) return
      if (event.key === "Enter" && type === "single") {
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
      if (type === "single") items[next].click()
    }
    this.el.addEventListener("keydown", this.onKeyDown)
  },
  destroyed() {
    this.el.removeEventListener("keydown", this.onKeyDown)
  }
}

export const UrUiHooks = { UrUiTabs, UrUiAvatarImage, UrUiCheckbox, UrUiRadioGroup, UrUiProgress, UrUiSlider, UrUiToggleGroup }
export default UrUiHooks
