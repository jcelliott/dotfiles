-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Deskflow: keep modifiers inside input capture (works around a Hyprland EIS keyboard-reset bug)
hl.config({ input_capture = { capture_modifiers = true } })

-- Steam's floating main window can drift fully off its monitor while staying
-- mapped. Relaunching Steam then only focuses that window, so the map-time
-- center rule never re-runs. Re-center it whenever it gains focus off screen.
hl.on("window.active", function(window)
  if not window or window.class ~= "steam" or not window.floating or not window.monitor then
    return
  end
  local m = window.monitor
  local right, bottom = m.x + m.width / m.scale, m.y + m.height / m.scale
  local at, size = window.at, window.size
  if at.x + size.x <= m.x or at.x >= right or at.y + size.y <= m.y or at.y >= bottom then
    hl.dispatch(hl.dsp.window.center({ window = window }))
  end
end)

-- Big Picture is Steam's TV/controller UI, so give it the whole screen instead
-- of Omarchy's default floating Steam window.
o.window({ class = "^steam$", title = "^Steam Big Picture Mode$" }, { fullscreen = true })

-- Work windows get the current theme's red border, focused or not, so they
-- stand apart without a title bar: web apps in the Work Chromium profile
-- (--profile-directory=Default) and Firefox started with --name firefox-work.
-- Regular Chromium and Firefox windows have class "chromium" or "firefox" and
-- keep the theme border.
local function theme_color(name)
  local f = io.open(os.getenv("HOME") .. "/.local/state/omarchy/current/theme/colors.toml")
  if not f then
    return nil
  end
  local hex = f:read("a"):match("\n" .. name .. ' = "#(%x+)"')
  f:close()
  return hex
end

local work_red = theme_color("red")
if work_red then
  o.window({ class = "^(chrome-.*-Default|firefox-work)$" }, {
    border_color = "rgba(" .. work_red .. "ff) rgba(" .. work_red .. "aa)",
  })
end

require("hypr.omacast")
