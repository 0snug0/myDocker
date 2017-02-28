local socket = require("socket")
-- local redis = require("resty.redis")

-- does not take into account other xff headers.
local xff_header = ngx.var.http_x_forwarded_for
local debug_header = ngx.var.http_supersecret_ip
local lookup = socket.dns
local time_now = os.date("%Y%m%d%H")


local function lkup(ip)
	-- split IP address to reverse. This is due to 
	-- the way project honeypot does DNS lookups
	local a,b,c,d = string.match(ip, "(%d+).(%d+).(%d+).(%d+)")
	local revip = d .. "." .. c .. "." .. b .. "." .. a
	-- local lkup_ip = '10.20.30.40'
	local lkup_ip = lookup.toip("valywiquaath." .. revip .. ".dnsbl.httpbl.org")
	ngx.var.bl_ip = lkup_ip
	if lkup_ip then
		-- split IP addresses for easier actions
		local lkup_unused,lkup_last_day,lkup_score,lkup_type = string.match(lkup_ip,
													"(%d+).(%d+).(%d+).(%d+)")
		-- Build lookup table
		lkup_table = {}
		lkup_table['lkup_ip'] = lkup_ip
		lkup_table['lkup_unused'] = tonumber(lkup_unused)
		lkup_table['lkup_last_day'] = tonumber(lkup_last_day)
		lkup_table['lkup_score'] = tonumber(lkup_score)
		lkup_table['lkup_type'] = tonumber(lkup_type)
		return lkup_table
	else
		return 
	end
end

local function block_action(lkup_table)
	-- return ngx.say(lkup_score)
	if lkup_table['lkup_score'] > 10 then
		ngx.status = 503
		ngx.header.content_type = 'text/html'
		ngx.header.cache_control = '60000'
		ngx.say('You\'ve been blocked from visiting this site')
		ngx.exit(503)
		return
	else
		return
	end
end

local function process_action()
	if not debug_header or debug_header == '' then
		if not lkup(xff_header) then
			return
		else
			local lkup_score = lkup(xff_header) -- ['lkup_score']
			return block_action(lkup_score)
		end
	else
		if not lkup(debug_header) then
			return
		else
			local lkup_score = lkup(debug_header) -- ['lkup_score']
			return block_action(lkup_score)
		end
	end
end

process_action()