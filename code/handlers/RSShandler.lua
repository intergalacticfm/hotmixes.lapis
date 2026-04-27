local to_json = require("lapis.util").to_json
local escape = require("lapis.util").escape
local autoload = require("lapis.util").autoload
local config = require("lapis.config")
local hotmixes = autoload("hotmixes")

local function RSShandler(self)

    local path = config.get().mount .. self.titles.url
    local latest_path, latest_name, latest_size, latest_date = hotmixes.utils.rss_latest( path )

    local host = self.req.parsed_url.scheme .. '://' .. self.req.parsed_url.host
    self.datapath = host .. '/data/' .. self.titles.url .. '/'
    self.latestpath = latest_path
    self.latestname = latest_name
    self.latestsize = latest_size
    self.latestdate = latest_date
    self.datenow = hotmixes.utils.rss_date_now()

    return { content_type = "application/rss+xml", layout = require "views.rss" }
end

return RSShandler
