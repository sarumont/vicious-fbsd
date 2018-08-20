---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local assert = assert
local error = error
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { find = string.find }
local helpers = require("vicious.helpers")
-- }}}


-- Net: provides state and usage statistics of a specific network interface
module("vicious.widgets.net")

-- {{{ Net widget type
local function worker(format, interface)
   local cmd = assert(io.popen("/usr/local/bin/ifstat -n -i "..interface.." 0.1 1 2>&1", "r"), "Requires ifstat")
   local output = cmd:read("*all")
   cmd:close()
   local num_pat = "[ ]+([%d]+[%.][%d]+)[ ]+([%d]+[%.][%d]+)"
   local _, _, kb_in, kb_out = string.find(output, num_pat)

   assert(kb_in, "Bad interface")
   assert(kb_out, "Bad inteface")

   kb_in = tonumber(kb_in)
   kb_out = tonumber(kb_out)

   local args = {}

   args["{rx}"] = kb_in
   args["{tx}"] = kb_out

   return args
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
