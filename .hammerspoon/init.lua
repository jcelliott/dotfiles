-- Hyper+click on a link opens it on osmium instead of here.
--
-- Hammerspoon is the default browser, so every http(s) link passes through
-- hs.urlevent.httpCallback. A Hyper (ctrl+alt+shift+cmd) click arms a short
-- window during which the next link is sent to osmium over Taildrop; any other
-- link goes straight to the real browser. The click's modifiers are stripped,
-- because macOS treats ctrl+click as a right-click.

local REAL_BROWSER = "org.mozilla.firefox"
-- Homebrew's CLI, else the standalone app's wrapper script. The app binary acts as the CLI
-- only when invoked as lowercase "tailscale"; as "Tailscale" it tries to start the GUI and
-- exits 0, which would look like a successful send.
local HOMEBREW_TAILSCALE = "/opt/homebrew/bin/tailscale"
local TAILSCALE = hs.fs.attributes(HOMEBREW_TAILSCALE) and HOMEBREW_TAILSCALE or "/usr/local/bin/tailscale"
local TARGET = "osmium:"
local ARM_SECONDS = 3

local forwardUntil = 0
local stripping = false

local function isHyper(flags)
  return flags.cmd and flags.alt and flags.ctrl and flags.shift
end

local types = hs.eventtap.event.types
clickTap = hs.eventtap.new({ types.leftMouseDown, types.leftMouseDragged, types.leftMouseUp }, function(e)
  local t = e:getType()
  if t == types.leftMouseDown and isHyper(e:getFlags()) then
    stripping = true
    forwardUntil = hs.timer.secondsSinceEpoch() + ARM_SECONDS
  end
  if stripping then
    e:setFlags({})
    if t == types.leftMouseUp then stripping = false end
  end
  return false
end):start()

-- macOS disables event taps that stall; turn it back on if that happens.
clickTapWatchdog = hs.timer.doEvery(5, function()
  if not clickTap:isEnabled() then clickTap:start() end
end)

local function openHere(url)
  hs.urlevent.openURLWithBundle(url, REAL_BROWSER)
end

local function sendToOsmium(url)
  -- The .linkdrop suffix tells osmium's receiver this file is a link, not a download.
  local path = hs.fs.temporaryDirectory():gsub("/$", "") .. "/link-" .. hs.host.uuid() .. ".linkdrop"
  local f = io.open(path, "w")
  f:write(url)
  f:close()
  hs.task.new(TAILSCALE, function(code)
    os.remove(path)
    if code == 0 then
      hs.alert.show("Opened on osmium", 0.8)
    else
      hs.alert.show("Couldn't reach osmium, opening here")
      openHere(url)
    end
  end, { "file", "cp", path, TARGET }):start()
end

hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
  if hs.timer.secondsSinceEpoch() < forwardUntil then
    forwardUntil = 0
    sendToOsmium(fullURL)
  else
    openHere(fullURL)
  end
end
