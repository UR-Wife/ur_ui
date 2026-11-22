// Dev-only Storybook bundle: registers ur_ui's colocated hooks, the same way a
// host app's app.js does (see USAGE.md).
import { hooks } from "phoenix-colocated/ur_ui"

window.storybook = { Hooks: hooks }
