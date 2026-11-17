-- Self-check for dictation.lua with stubbed Hyprland and voxtype state.
-- Run: lua ~/.config/hypr/dictation_check.lua
local dir = arg[0]:match("^(.*)/") or "."
local state, cmds, timers

hl = {
  exec_cmd = function(cmd) table.insert(cmds, cmd) end,
  timer = function(fn) table.insert(timers, fn) end,
}
io.open = function()
  return { read = function() return state end, close = function() end }
end

local function fresh()
  state, cmds, timers = "idle", {}, {}
  return dofile(dir .. "/dictation.lua")
end

local function expect(want)
  assert(table.concat(cmds, ",") == table.concat(want, ","),
    "got [" .. table.concat(cmds, ",") .. "] want [" .. table.concat(want, ",") .. "]")
end

-- Hold past the threshold: push-to-talk.
local d = fresh()
d.press(); timers[1](); state = "recording"; d.release()
expect({ "voxtype record start", "voxtype record stop" })

-- Tap: keeps recording until the next press, whose release does nothing.
d = fresh()
d.press(); d.release(); timers[1](); state = "recording"
expect({ "voxtype record start" })
d.press(); d.release()
expect({ "voxtype record start", "voxtype record stop" })

-- A second press before voxtype reports recording ignores the first press's timer.
d = fresh()
d.press(); d.release(); d.press(); timers[1](); d.release()
expect({ "voxtype record start", "voxtype record start" })

print("dictation ok")
