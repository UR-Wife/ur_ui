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

// tooltip/1: as in Radix Tooltip, hovering or focusing the trigger opens the
// content after the configured delay (hover is delayed; focus opens instantly)
// and Escape, blur, clicking the trigger or scrolling closes it. Leaving the
// trigger closes after a short grace window and the bubble itself stays
// hoverable, so the pointer can cross the `side_offset` gap without closing it.
// The content is shown beside the trigger per `side`/`side-offset`; when the
// preferred side would clip it at the viewport edge it is flipped to the
// opposite side and clamped back on screen. Coordinates are measured against the
// viewport but written in the fixed-position containing block's frame, so a
// transformed ancestor does not displace the bubble. Positioning runs through
// the CSSOM (el.style) so the markup carries no inline style and works under a
// strict Content-Security-Policy. While open, `data-state` is
// "delayed-open"/"instant-open" and the trigger gets `aria-describedby`
// pointing at the content; the exit animation finishes before the content is
// hidden.
const UrUiTooltip = {
  mounted() {
    this.trigger = null
    this.content = this.el.querySelector('[data-slot="tooltip-content"]')
    this.requestedSide = this.content?.dataset.side || "top"
    this.openTimerRef = 0
    this.closeTimerRef = 0
    this.leaveTimerRef = 0
    this.repositionFrame = 0
    this.globalAttached = false
    this.contentBound = null

    this.onTriggerEnter = () => {
      window.clearTimeout(this.leaveTimerRef)
      const delay = this.delayDuration()
      if (delay > 0) {
        window.clearTimeout(this.openTimerRef)
        this.openTimerRef = window.setTimeout(() => this.open("delayed-open"), delay)
      } else {
        this.open("instant-open")
      }
    }
    // Close after a short grace window so the pointer can cross the
    // `side_offset` gap onto the (still hoverable) bubble without closing it.
    this.onTriggerLeave = () => {
      window.clearTimeout(this.openTimerRef)
      window.clearTimeout(this.leaveTimerRef)
      this.leaveTimerRef = window.setTimeout(() => this.close(), this.leaveDuration())
    }
    this.onContentEnter = () => this.keepOpen()
    this.onContentLeave = () => this.close()
    this.onFocus = () => this.open("instant-open")
    this.onBlur = () => this.close()
    this.onClick = () => this.close()
    this.onDocumentKeyDown = (event) => {
      if (event.key === "Escape" && this.isOpen()) this.close()
    }
    this.onScroll = () => this.requestReposition()
    this.onResize = () => this.requestReposition()

    this.bindTrigger()
    this.bindContent()
  },
  updated() {
    const next = this.el.querySelector('[data-slot="tooltip-content"]')
    if (next !== this.content) {
      this.content = next
    }
    this.requestedSide = next?.dataset.side || "top"
    this.bindTrigger()
    this.bindContent()
  },
  destroyed() {
    this.detachTrigger()
    this.detachContent()
    this.detachGlobalListeners()
    window.clearTimeout(this.openTimerRef)
    window.clearTimeout(this.closeTimerRef)
    window.clearTimeout(this.leaveTimerRef)
    if (this.repositionFrame) window.cancelAnimationFrame(this.repositionFrame)
  },
  // Rebind listeners when a LiveView update replaces the trigger element (or
  // swaps in a new one under a different id).
  bindTrigger() {
    const next = this.el.querySelector('[data-slot="tooltip-trigger"]')
    if (next === this.trigger) return
    this.detachTrigger()
    this.trigger = next
    if (!this.trigger) return
    this.trigger.addEventListener("mouseenter", this.onTriggerEnter)
    this.trigger.addEventListener("focus", this.onFocus)
    this.trigger.addEventListener("mouseleave", this.onTriggerLeave)
    this.trigger.addEventListener("blur", this.onBlur)
    this.trigger.addEventListener("click", this.onClick)
  },
  detachTrigger() {
    if (!this.trigger) return
    this.trigger.removeEventListener("mouseenter", this.onTriggerEnter)
    this.trigger.removeEventListener("focus", this.onFocus)
    this.trigger.removeEventListener("mouseleave", this.onTriggerLeave)
    this.trigger.removeEventListener("blur", this.onBlur)
    this.trigger.removeEventListener("click", this.onClick)
    this.trigger = null
  },
  // Keep the bubble hoverable: bind enter/leave on the content so a pointer
  // moving from the trigger onto it does not close it (and rebind when a
  // LiveView update swaps the content node).
  bindContent() {
    const next = this.content
    if (next === this.contentBound) return
    this.detachContent()
    this.contentBound = next
    if (!this.contentBound) return
    this.contentBound.addEventListener("mouseenter", this.onContentEnter)
    this.contentBound.addEventListener("mouseleave", this.onContentLeave)
  },
  detachContent() {
    if (!this.contentBound) return
    this.contentBound.removeEventListener("mouseenter", this.onContentEnter)
    this.contentBound.removeEventListener("mouseleave", this.onContentLeave)
    this.contentBound = null
  },
  attachGlobalListeners() {
    if (this.globalAttached) return
    this.globalAttached = true
    document.addEventListener("keydown", this.onDocumentKeyDown)
    window.addEventListener("resize", this.onResize)
    window.addEventListener("scroll", this.onScroll, true)
  },
  detachGlobalListeners() {
    if (!this.globalAttached) return
    this.globalAttached = false
    document.removeEventListener("keydown", this.onDocumentKeyDown)
    window.removeEventListener("resize", this.onResize)
    window.removeEventListener("scroll", this.onScroll, true)
  },
  // The hover delay is read on every hover so a LiveView-assigned
  // `delay_duration` change takes effect without a remount.
  delayDuration() {
    return Number(
      this.el.dataset.delayDuration ??
        this.el.closest('[data-slot="tooltip-provider"]')?.dataset.delayDuration ??
        0
    )
  },
  isOpen() {
    return this.content && !this.content.hidden
  },
  setState(state) {
    this.el.setAttribute("data-state", state)
    if (this.trigger) this.trigger.setAttribute("data-state", state)
    if (this.content) this.content.setAttribute("data-state", state)
  },
  open(state) {
    if (!this.trigger || !this.content) return
    window.clearTimeout(this.openTimerRef)
    window.clearTimeout(this.closeTimerRef)
    window.clearTimeout(this.leaveTimerRef)
    this.stateName = state
    this.attachGlobalListeners()
    // Take the content out of flow and measure it before it becomes visible.
    this.content.style.position = "fixed"
    this.content.style.visibility = "hidden"
    this.content.hidden = false
    this.place()
    this.content.style.visibility = ""
    this.setState(state)
    this.trigger.setAttribute("aria-describedby", this.content.id)
  },
  // The pointer reached the bubble: cancel an imminent close and, if a leave
  // already started the exit animation, restore the open state.
  keepOpen() {
    window.clearTimeout(this.openTimerRef)
    window.clearTimeout(this.leaveTimerRef)
    window.clearTimeout(this.closeTimerRef)
    if (this.content && !this.content.hidden && this.el.getAttribute("data-state") === "closed") {
      this.attachGlobalListeners()
      this.setState(this.stateName || "instant-open")
      if (this.trigger) this.trigger.setAttribute("aria-describedby", this.content.id)
    }
  },
  // Grace period (ms) after a pointer-leave before closing, matching Radix's
  // hoverable Tooltip content across the side offset.
  leaveDuration() {
    return 100
  },
  // Position (and, if needed, flip and clamp) the content against the viewport.
  place() {
    if (!this.trigger || !this.content) return
    const triggerRect = this.trigger.getBoundingClientRect()
    // offsetWidth/offsetHeight are the layout size without transforms, so the
    // enter animation's zoom/slide cannot skew the coordinates we store while
    // the bubble is animating.
    const contentWidth = this.content.offsetWidth
    const contentHeight = this.content.offsetHeight
    const preferred = this.requestedSide || "top"
    const offset = Number(this.content.dataset.sideOffset || 0)
    const margin = 8
    const viewportWidth = document.documentElement.clientWidth
    const viewportHeight = document.documentElement.clientHeight
    const opposite = { top: "bottom", bottom: "top", left: "right", right: "left" }

    const position = (side) => {
      switch (side) {
        case "bottom":
          return {
            side,
            left: triggerRect.left + triggerRect.width / 2 - contentWidth / 2,
            top: triggerRect.bottom + offset
          }
        case "left":
          return {
            side,
            left: triggerRect.left - contentWidth - offset,
            top: triggerRect.top + triggerRect.height / 2 - contentHeight / 2
          }
        case "right":
          return {
            side,
            left: triggerRect.right + offset,
            top: triggerRect.top + triggerRect.height / 2 - contentHeight / 2
          }
        case "top":
        default:
          return {
            side: "top",
            left: triggerRect.left + triggerRect.width / 2 - contentWidth / 2,
            top: triggerRect.top - contentHeight - offset
          }
      }
    }

    const fits = (candidate) =>
      candidate.left >= margin &&
      candidate.top >= margin &&
      candidate.left + contentWidth <= viewportWidth - margin &&
      candidate.top + contentHeight <= viewportHeight - margin

    let chosen = position(preferred)
    if (!fits(chosen)) {
      const flipped = position(opposite[preferred] ?? "top")
      if (fits(flipped)) chosen = flipped
    }

    let left = Math.min(Math.max(chosen.left, margin), viewportWidth - contentWidth - margin)
    let top = Math.min(Math.max(chosen.top, margin), viewportHeight - contentHeight - margin)

    // A transformed ancestor becomes the containing block for the fixed
    // content, so viewport coordinates would be offset (and scaled) again.
    // Translate them into that ancestor's frame, accounting for its border.
    const containingBlock = this.fixedContext()
    if (containingBlock) {
      const r = containingBlock.getBoundingClientRect()
      const sx = r.width / containingBlock.offsetWidth || 1
      const sy = r.height / containingBlock.offsetHeight || 1
      const viewportX = left
      const viewportY = top
      left = (viewportX - r.left) / sx - containingBlock.clientLeft
      top = (viewportY - r.top) / sy - containingBlock.clientTop
    }

    this.content.style.left = `${left}px`
    this.content.style.top = `${top}px`
    this.content.setAttribute("data-side", chosen.side)
  },
  // Walk up from the content to the nearest ancestor that establishes the
  // containing block for `position: fixed` (transform, perspective, filter,
  // backdrop-filter, will-change or paint/layout containment). Returns null when
  // the viewport is the containing block.
  fixedContext() {
    let el = this.content?.parentElement
    while (el && el !== document.body) {
      const style = window.getComputedStyle(el)
      if (
        style.transform !== "none" ||
        style.perspective !== "none" ||
        style.filter !== "none" ||
        style.backdropFilter !== "none" ||
        style.willChange === "transform" ||
        style.willChange === "perspective" ||
        style.willChange === "filter" ||
        style.contain === "paint" ||
        style.contain === "strict" ||
        style.contain === "content"
      ) {
        return el
      }
      el = el.parentElement
    }
    return null
  },
  // Coalesce scroll/resize into one reposition per animation frame, so the
  // bubble follows the trigger (as Radix's auto-update does) without a layout
  // storm while the user scrolls.
  requestReposition() {
    if (this.repositionFrame) return
    this.repositionFrame = window.requestAnimationFrame(() => {
      this.repositionFrame = 0
      if (this.isOpen()) this.place()
    })
  },
  close() {
    if (!this.content) return
    window.clearTimeout(this.openTimerRef)
    this.detachGlobalListeners()
    this.setState("closed")
    if (this.trigger) this.trigger.removeAttribute("aria-describedby")
    if (this.content.hidden) return
    // Let the `data-[state=closed]:animate-out` exit animation finish before
    // the bubble is hidden.
    window.clearTimeout(this.closeTimerRef)
    this.closeTimerRef = window.setTimeout(() => this.hide(), this.closeDuration())
  },
  hide() {
    if (!this.content) return
    // A re-open may have landed while the exit animation was running.
    if (this.el.getAttribute("data-state") !== "closed") return
    this.content.hidden = true
    this.content.style.position = ""
    this.content.style.left = ""
    this.content.style.top = ""
    this.content.style.visibility = ""
  },
  closeDuration() {
    if (!this.content) return 0
    const value = parseFloat(window.getComputedStyle(this.content).animationDuration)
    return Number.isFinite(value) ? Math.ceil(value * 1000) : 0
  }
}

export const UrUiHooks = { UrUiTabs, UrUiAvatarImage, UrUiCheckbox, UrUiRadioGroup, UrUiProgress, UrUiSlider, UrUiToggleGroup, UrUiTooltip }
export default UrUiHooks
