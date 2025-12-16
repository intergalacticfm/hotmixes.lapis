local to_json = require("lapis.util").to_json
local escape = require("lapis.util").escape
local autoload = require("lapis.util").autoload
local config = require("lapis.config")
local hotmixes = autoload("hotmixes")

local function Latesthandler(self)

    local path = config.get().mount .. self.titles.url
    local latest_path, latest_name = hotmixes.utils.these_latest( path )

    local host = self.req.parsed_url.scheme .. '://' .. self.req.parsed_url.host
    local data_path = host .. '/data/' .. self.titles.url .. '/'
    local latest_json = {}

    for i, file in ipairs(latest_path) do
        latest_json[latest_name[i]] = data_path .. escape(file)
    end

    return { json = latest_json }
end

return Latesthandler
