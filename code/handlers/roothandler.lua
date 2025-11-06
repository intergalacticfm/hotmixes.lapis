local to_json = require("lapis.util").to_json
local autoload = require("lapis.util").autoload
local config = require("lapis.config")

-- print(to_json(config.get()))

local hotmixes = autoload("hotmixes")

local function Roothandler(self)
    local stuff = hotmixes.utils.these_files( hotmixes.utils.data_path )

    local latest_path, latest_name = hotmixes.utils.these_latest()

    self.total = hotmixes.utils.total_files_dir( config.get().mount )
    self.uri = hotmixes.utils.request_path
    self.path = '/data' .. hotmixes.utils.request_path
    self.dirs = stuff.dirs
    self.files = stuff.files
    self.images = stuff.images
    self.latestpath = latest_path
    self.latestname = latest_name

    return { render = "root" }

end

return Roothandler
