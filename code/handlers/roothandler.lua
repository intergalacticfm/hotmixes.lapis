local config = require("lapis.config")
local utils = require("hotmixes.utils")
local prc_layout = require("views.prc_layout")

local function Roothandler(self)

    local request_path = utils.request_path()
    local path = config.get().mount .. self.titles.path
    local stuff = utils.these_files( path .. request_path )
    local latest_path, latest_name = utils.these_latest( path )


    self.total = utils.total_files_dir( path )
    self.uri = request_path
    self.path = '/data/' .. self.titles.path .. request_path
    self.dirs = stuff.dirs
    self.files = stuff.files
    self.images = stuff.images
    self.latestpath = latest_path
    self.latestname = latest_name
    self.functions = { hotesc = utils.hotesc }

    if self.titles['url'] == "panamaracing.club" then
        return { render = "root", layout = prc_layout }
    else
        return { render = "root" }
    end

end

return Roothandler
