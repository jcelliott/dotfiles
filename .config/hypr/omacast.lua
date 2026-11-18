-- omacast launcher bindings, laid out like `omacast setup hyprland` writes them,
-- but on SUPER+SPACE (was: Omarchy menu) instead of ALT+SPACE.
-- `omacast uninstall` removes this file and its require in hyprland.lua.
-- The global shortcut reaches the plugin directly, so no process starts per keypress.
o.rebind("SUPER + SPACE", "omacast launcher", hl.dsp.global("omacast:toggle"), { submap_universal = true })
-- While the launcher is open, the plugin puts Hyprland in this submap so Super+J/K
-- (and every other Super key Hyprland would grab) reach omacast as arrow keys.
hl.define_submap("omacast", function()
  hl.bind("SUPER + F24", hl.dsp.no_op()) -- a submap needs one bind to exist
end)
-- Blur behind the launcher; it only shows under Omarchy's Glassy windows.
hl.layer_rule({ match = { namespace = "^omacast$" }, blur = true, ignore_alpha = 0.3 })
