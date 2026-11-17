-- Hybrid voxtype dictation key: hold for push-to-talk, tap to toggle.
-- A press while voxtype is recording stops it. Otherwise the press starts
-- recording, and its release stops it only if the key was held for at least
-- HOLD_MS; a shorter tap leaves it recording until the next press.
local HOLD_MS = 300

local M = {}
local pending = false -- a press started recording and its release hasn't arrived
local held = false
local generation = 0 -- lets a stale hold timer from an earlier press be ignored

-- voxtype writes idle/recording/transcribing here (state_file = "auto").
local function recording()
  local file = io.open((os.getenv("XDG_RUNTIME_DIR") or "") .. "/voxtype/state", "r")
  if not file then return false end
  local state = file:read("*l")
  file:close()
  return state == "recording"
end

function M.press()
  if recording() then
    pending = false
    hl.exec_cmd("voxtype record stop")
    return
  end

  generation = generation + 1
  local this_press = generation
  pending, held = true, false
  hl.exec_cmd("voxtype record start")
  hl.timer(function()
    if this_press == generation then held = true end
  end, { timeout = HOLD_MS, type = "oneshot" })
end

function M.release()
  if not pending then return end
  pending = false
  if held then hl.exec_cmd("voxtype record stop") end
end

return M
