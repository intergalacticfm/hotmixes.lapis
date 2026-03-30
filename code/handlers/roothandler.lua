local to_json = require("lapis.util").to_json
local autoload = require("lapis.util").autoload
local escape = require("lapis.util").escape
local config = require("lapis.config")
local hotmixes = autoload("hotmixes")

local function Roothandler(self)

    local path = config.get().mount .. self.titles.url
    local stuff = hotmixes.utils.these_files( path .. hotmixes.utils.request_path )
    local latest_path, latest_name = hotmixes.utils.these_latest( path )

    self.total = hotmixes.utils.total_files_dir( path )
    self.uri = escape(hotmixes.utils.request_path)
    self.path = escape('/data/' .. self.titles.url .. hotmixes.utils.request_path)
    self.dirs = stuff.dirs
    self.files = stuff.files
    self.images = stuff.images
    self.latestpath = latest_path
    self.latestname = latest_name

    if self.titles['url'] == "panamaracing.club" then
        return { render = "root", layout = require "views.prc_layout" }
    else
        return { render = "root" }
    end

end

return Roothandler
