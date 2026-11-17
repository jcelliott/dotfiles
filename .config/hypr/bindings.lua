-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Dictation on SUPER+ALT+SPACE (was the apps menu): hold to talk, tap to toggle.
-- The release bind ignores modifiers so letting go of SUPER or ALT first still
-- ends push-to-talk, and passes the release through so a plain SPACE still types.
-- Omarchy's own dictation keys (SUPER+CTRL+X toggle, F9 push-to-talk) are dropped.
local dictation = require("hypr.dictation")
hl.unbind("SUPER + CTRL + X")
hl.unbind("F9")
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + ALT + SPACE", "Dictation (hold to talk, tap to toggle)", dictation.press)
o.bind("SUPER + ALT + SPACE", nil, dictation.release, { release = true, ignore_mods = true, non_consuming = true })

-- Vim-style focus and window movement
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- Drop the arrow-key versions of focus and swap
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + DOWN")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + SHIFT + LEFT")
hl.unbind("SUPER + SHIFT + DOWN")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + RIGHT")

-- Lock moves to SUPER+ALT+ESCAPE; hardware menu unbound
hl.unbind("SUPER + CTRL + L")
hl.unbind("SUPER + CTRL + H")
o.bind("SUPER + ALT + ESCAPE", "Lock system", "omarchy-system-lock")

-- Resize mode: SUPER+; enters, h/l narrower/wider, k/j shorter/taller,
-- SHIFT for bigger steps, CTRL for finer ones, ESCAPE or RETURN leaves. Shown in the bar by josh.submap.
local function resize_by(x, y)
  return hl.dsp.window.resize({ x = x, y = y, relative = true })
end

-- Width steps on scrolling workspaces use colresize (a fraction of the screen),
-- because a plain resize stops at the screen edge there; colresize scrolls instead.
-- The fraction is worked out from the monitor's logical width so steps match the
-- pixel steps elsewhere.
local function resize_width(pixels)
  return function()
    local workspace = hl.get_active_workspace()
    local monitor = hl.get_active_monitor()
    if workspace and monitor and workspace.tiled_layout == "scrolling" then
      local fraction = pixels / (monitor.width / monitor.scale)
      hl.dispatch(hl.dsp.layout(string.format("colresize %+.4f", fraction)))
    else
      hl.dispatch(resize_by(pixels, 0))
    end
  end
end

hl.define_submap("resize", function()
  hl.bind("H", resize_width(-50), { repeating = true, description = "Narrower" })
  hl.bind("L", resize_width(50), { repeating = true, description = "Wider" })
  hl.bind("K", resize_by(0, -50), { repeating = true, description = "Shorter" })
  hl.bind("J", resize_by(0, 50), { repeating = true, description = "Taller" })
  hl.bind("SHIFT + H", resize_width(-200), { repeating = true, description = "Much narrower" })
  hl.bind("SHIFT + L", resize_width(200), { repeating = true, description = "Much wider" })
  hl.bind("SHIFT + K", resize_by(0, -200), { repeating = true, description = "Much shorter" })
  hl.bind("SHIFT + J", resize_by(0, 200), { repeating = true, description = "Much taller" })
  hl.bind("CTRL + H", resize_width(-10), { repeating = true, description = "Slightly narrower" })
  hl.bind("CTRL + L", resize_width(10), { repeating = true, description = "Slightly wider" })
  hl.bind("CTRL + K", resize_by(0, -10), { repeating = true, description = "Slightly shorter" })
  hl.bind("CTRL + J", resize_by(0, 10), { repeating = true, description = "Slightly taller" })
  hl.bind("ESCAPE", hl.dsp.submap("reset"), { description = "Exit resize mode" })
  hl.bind("RETURN", hl.dsp.submap("reset"), { description = "Exit resize mode" })
end)

o.bind("SUPER + semicolon", "Resize mode", hl.dsp.submap("resize"))

-- Mac-style app shortcuts: SUPER+key sends CTRL+key, like Omarchy's universal
-- copy/paste. Skipped in terminals, where CTRL+R/T/W mean something else.
-- Helpers mirror default/hypr/bindings/clipboard.lua, where they're local.
local function send_shortcut_once(mods, key)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  for _, tag in ipairs(window and window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end
  return false
end

local function app_shortcut(key)
  return function()
    if not active_window_is_terminal() then
      send_shortcut_once("CTRL", key)
    end
  end
end

o.bind("SUPER + R", "Refresh", app_shortcut("R"))

hl.unbind("SUPER + T")
o.bind("SUPER + T", "New tab", app_shortcut("T"))

hl.unbind("SUPER + W")
o.bind("SUPER + W", "Close tab", app_shortcut("W"))
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Leader mode: SUPER+, then one key. Drops back to normal after any key;
-- unmapped keys just exit. Shown in the bar by josh.submap.
-- In the scrolling layout, s stacks the next column's window under this one (consume)
-- and e un-stacks the bottom window back out (expel); togglesplit is dwindle-only.
local function split_or_consume()
  local workspace = hl.get_active_workspace()
  if workspace and workspace.tiled_layout == "scrolling" then
    hl.dispatch(hl.dsp.layout("consume"))
  else
    hl.dispatch(hl.dsp.layout("togglesplit"))
  end
end

hl.define_submap("leader", "reset", function()
  hl.bind("L", hl.dsp.exec_cmd("omarchy-hyprland-workspace-layout-toggle"), { description = "Toggle workspace layout" })
  hl.bind("T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle window floating/tiling" })
  hl.bind("N", hl.dsp.exec_cmd("omarchy-shell notifications showHistory"), { description = "Open notification history" })
  hl.bind("BackSpace", hl.dsp.exec_cmd("omarchy-shell notifications dismissOne"), { description = "Dismiss last notification" })
  hl.bind("Delete", hl.dsp.exec_cmd("omarchy-shell notifications dismissAll"), { description = "Dismiss all notifications" })
  hl.bind("S", split_or_consume, { description = "Toggle split / stack next window below" })
  hl.bind("E", hl.dsp.layout("expel"), { description = "Unstack bottom window" })
  hl.bind("catchall", hl.dsp.submap("reset"), { description = "Exit leader mode" })
end)

hl.unbind("SUPER + comma")
o.bind("SUPER + comma", "Leader mode", hl.dsp.submap("leader"))

-- Deskflow: Hyper+H/L switch screens while the cursor is on osmium. Input capture
-- only starts on real pointer motion across the screen edge, so nudge the pointer there.
o.bind("CTRL + ALT + SHIFT + SUPER + H", "Deskflow: switch left", "/home/josh/tmp/deskflow-hotkeys/deskflow-switch left")
o.bind("CTRL + ALT + SHIFT + SUPER + L", "Deskflow: switch right", "/home/josh/tmp/deskflow-hotkeys/deskflow-switch right")
-- Hyper+P toggles Deskflow's lock to the current screen (on a Mac it's a Deskflow hotkey).
-- Shown in the bar by josh.cursorlock.
o.bind("CTRL + ALT + SHIFT + SUPER + P", "Deskflow: lock cursor to screen", "/home/josh/tmp/deskflow-hotkeys/deskflow-lock-toggle")

-- Hyper+1..0 switch workspaces too, alongside SUPER+1..0 (trial: keep whichever feels better).
-- Same keycodes as Omarchy's loop in default/hypr/bindings/tiling.lua.
for workspace = 1, 10 do
  o.bind("CTRL + ALT + SHIFT + SUPER + code:" .. tostring(workspace + 9), "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
end

-- Scratchpad on ALT+` (keycode so SHIFT still matches; SHIFT+` is asciitilde).
hl.unbind("SUPER + S")
hl.unbind("SUPER + ALT + S")
o.bind("ALT + code:49", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("ALT + SHIFT + code:49", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Mac-style switching. ALT+TAB flips between the current and last-focused window
-- (across workspaces), instead of Omarchy's cycle through the current workspace;
-- ALT+SHIFT+TAB still cycles. SUPER+TAB does the same for workspaces.
hl.unbind("ALT + TAB")
o.bind("ALT + TAB", "Focus last window", hl.dsp.focus({ last = true }))
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Focus last workspace", hl.dsp.focus({ workspace = "previous" }))

-- SUPER+` cycles through windows of the active app, like CMD+` on a Mac; SHIFT goes
-- backwards. Ordered by when each window opened, and skips special workspaces
-- such as the scratchpad. Keycode so SHIFT still matches.
local function cycle_app_windows(step)
  return function()
    local active = hl.get_active_window()
    if not active then return end

    local windows = {}
    for _, window in ipairs(hl.get_windows()) do
      if window.class == active.class and window.workspace and not window.workspace.special then
        table.insert(windows, window)
      end
    end
    if #windows < 2 then return end

    table.sort(windows, function(a, b) return a.stable_id < b.stable_id end)
    for i, window in ipairs(windows) do
      if window.address == active.address then
        local target = windows[(i - 1 + step) % #windows + 1]
        hl.dispatch(hl.dsp.focus({ window = "address:" .. target.address }))
        return
      end
    end
  end
end

o.bind("SUPER + code:49", "Next window of this app", cycle_app_windows(1))
o.bind("SUPER + SHIFT + code:49", "Previous window of this app", cycle_app_windows(-1))
