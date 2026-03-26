local to_json = require("lapis.util").to_json
local escape = require("lapis.util").escape
local autoload = require("lapis.util").autoload
local config = require("lapis.config")
local hotmixes = autoload("hotmixes")

local function RSShandler(self)

    local path = config.get().mount .. self.titles.url
    local latest_path, latest_name = hotmixes.utils.these_latest( path )

    local host = self.req.parsed_url.scheme .. '://' .. self.req.parsed_url.host
    local data_path = host .. '/data/' .. self.titles.url .. '/'
    local latest_json = {}
    latest_json["files"] = {}

    self.latestpath = latest_path
    self.latestname = latest_name

    return { content_type = "text/rss", layout = require "views.rss" }
end

return RSShandler
