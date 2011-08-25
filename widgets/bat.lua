---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { format = string.format }
local helpers = require("vicious.helpers")
local io = { lines = io.lines, popen = io.popen }
local math = {
    min = math.min,
    floor = math.floor
}
-- }}}


-- Bat: provides state, charge, and remaining time for a requested battery
module("vicious.widgets.bat")


-- {{{ Battery widget type
local function worker(format, warg)
    --if not warg then return end

    local battery_state = {}
	battery_state["0"] = "↯" -- full
	battery_state["1"] = "-" -- unplugged/discharging
	battery_state["2"] = "+" -- charging
	unknown = "⌁"

	local fd = io.popen( 'sysctl -n hw.acpi.battery.life' )
	if not fd then
		return {unknown, "0", "N/A"}
	end
	local b_life = fd:read()
	fd:close()

	fd = io.popen( 'sysctl -n hw.acpi.battery.time' )
	local b_time = fd:read()
	fd:close()

	fd = io.popen( 'sysctl -n hw.acpi.battery.state' )
	local b_state = fd:read()
	fd:close()

    -- Get state information
	if b_time ~= "-1" then
		local time_h = math.floor( b_time / 60 )
		local time_m = b_time - 60*time_h
		time = string.format("%02d:%02d", time_h, time_m)
	else
		time = "N/A"
	end

    local state = battery_state[b_state] or unknown
    return {state, b_life, time}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
