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
    latest_json["files"] = {}

    for i, file in ipairs(latest_path) do
        local file_data = {}

        file_data["name"] = latest_name[i]
        file_data["url"] = data_path .. file

        table.insert(latest_json["files"], file_data)
    end

    return { json = latest_json }
end

return Latesthandler
