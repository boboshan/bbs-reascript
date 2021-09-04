--[[
 * ReaScript Name: bbs_Copy selected track names to clipboard
 * Description: Copy selected track names to clipboard
 * Instructions: Just run this action on selected tracks
 * Author: bbs
 * REAPER: 6
 * Version: 1.0
--]] --[[
 * Changelog:
 * v1.0 (2020-09-04)
  + Initial Release
 --]] -- ----- DEBUGGING ====>
 
local info = debug.getinfo(1, 'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2, -5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
    package.path = package.path .. ";" .. script_path:match("(.*" .. "\\" .. ")") .. "..\\Functions\\?.lua"
else
    package.path = package.path .. ";" .. script_path:match("(.*" .. "/" .. ")") .. "../Functions/?.lua"
end

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

time_os = reaper.time_precise()

-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

    local UNDO_STATE_TRACKCFG = 1
    local clipboard, index = reaper.CF_GetClipboard(''), 0

    if clipboard:len() < 1 or reaper.CountSelectedTracks(0) < 1 then
        reaper.defer(function()
        end) -- no undo point
    end

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    for line in clipboard:gmatch("([^\r\n]*)[\r\n]*") do
        local track = reaper.GetSelectedTrack(0, index)
        if not track then
            break
        end

        reaper.GetSetMediaTrackInfo_String(track, 'P_NAME', line, true)
        index = index + 1
    end

    reaper.Undo_EndBlock("My action", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

main()

reaper.UpdateArrange()

-- reaper.ShowMessageBox("Script executed in (s): "..tostring(reaper.time_precise() - time_os), "", 0)