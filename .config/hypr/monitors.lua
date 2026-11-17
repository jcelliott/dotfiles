-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
-- local omarchy_monitor_scale = "auto"
local omarchy_monitor_scale = 1.5

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
-- Steam is X11 and xwayland:force_zero_scaling hands it scale 1, so it sizes its own UI
hl.env("STEAM_FORCE_DESKTOPUI_SCALING", tostring(omarchy_monitor_scale))
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({
  output = "",
  -- mode = "2560x1440@120",
  mode = "3840x2160@120.00Hz",
  position = "auto",
  scale = omarchy_monitor_scale,
  -- use the color profile reported by the monitor
  cm = "edid",
  -- 10-bit output avoids banding from the edid gamut conversion
  bitdepth = 10
})

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
