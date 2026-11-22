// Dev-only Storybook bundle: registers ur_ui's LiveView hooks the same way a
// host app's app.js does (see USAGE.md).
import { UrUiHooks } from "../../assets/js/ur_ui_hooks.js"

window.storybook = { Hooks: UrUiHooks }
