---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local io = { lines = io.lines, popen = io.popen }
local setmetatable = setmetatable
local math = { floor = math.floor }
local string = { gmatch = string.gmatch }
-- }}}


-- Mem: provides RAM and Swap usage statistics
module("vicious.widgets.mem")


-- {{{ Memory widget type
local function worker(format)
    local mem = { buf = {}, swp = {} }

	-- get mem data frem sysctl
	local fd = io.popen( 'sysctl -n hw.pagesize' )
	local pagesize = fd:read();
	fd:close()

	fd = io.popen( 'sysctl -n vm.stats.vm.v_page_count' )
	local total_pages = fd:read();
	fd:close()

	fd = io.popen( 'sysctl -n vm.stats.vm.v_free_count' )
	local free_pages = fd:read();
	fd:close()

	fd = io.popen( 'sysctl -n vm.stats.vm.v_inactive_count' )
	local inact_pages = fd:read();
	fd:close()

	-- Calculate percentage
	mem.total = ( total_pages * pagesize )
	mem.free = ( free_pages + inact_pages ) * pagesize
	mem.inuse = ( total_pages - free_pages - inact_pages ) * pagesize
	mem.usep = math.floor( mem.inuse / mem.total * 100 )

	-- TODO:
	mem.swp.total = 0
	mem.swp.free = 0
	mem.swp.inuse = 0
	mem.swp.usep = 0

    return {mem.usep,     mem.inuse,     mem.total, mem.free,
            mem.swp.usep, mem.swp.inuse, mem.swp.t, mem.swp.f}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
