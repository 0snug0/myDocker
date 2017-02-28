local redis = require "resty.redis"
-- local resolver = require("resty.dns.resolver")

-- does not take into account other xff headers.
local xff_header = ngx.var.http_x_forwarded_for
local debug_header = ngx.var.http_supersecret_ip
local time_now = os.date("%Y%m%d%H")


local function lkup(ip)
	-- split IP address to reverse. This is due to 
	-- the way project honeypot does DNS lookups
	local a,b,c,d = string.match(ip, "(%d+).(%d+).(%d+).(%d+)")
	local revip = d .. "." .. c .. "." .. b .. "." .. a


	local r, err = resolver:new{
        nameservers = {"8.8.8.8", {"8.8.4.4", 53} },
        retrans = 5,  -- 5 retransmissions on receive timeout
        timeout = 2000,  -- 2 sec
    }

    if not r then
        ngx.say("failed to instantiate the resolver: ", err)
        return
    end

    local answers, err = r:query("www.google.com")
    if not answers then
        ngx.say("failed to query the DNS server: ", err)
        return
    end

    if answers.errcode then
        ngx.say("server returned error code: ", answers.errcode,
                ": ", answers.errstr)
    end

    for i, ans in ipairs(answers) do
        ngx.say(ans.name, " ", ans.address or ans.cname,
                " type:", ans.type, " class:", ans.class,
                " ttl:", ans.ttl)
    end

-- This is test code

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