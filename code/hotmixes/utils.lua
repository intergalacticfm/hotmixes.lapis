local lfs = require 'lfs_ffi'
local config = require("lapis.config").get()


-- setup
local request_uri = ngx.var.request_uri
request_uri = ngx.unescape_uri(request_uri)
ngx.log(ngx.ERR, request_uri)

if string.find(request_uri, "\"") or string.find(request_uri, "%`") or string.find(request_uri, "%$") then
    ngx.log(ngx.ERR, "Illegal request_uri")
    ngx.exit(500)
end

local request_path
if request_uri ~= '/' then
    request_path = request_uri .. '/'
else
    request_path = request_uri
end

local data_dir = config.mount
local data_path = data_dir .. request_path
-- setup


local utils =  {}

utils['request_path'] = request_path
utils['data_path'] = data_path

-- we want to know if something is an image
utils['match_image'] = function( file )
    local filext = file:match("[^.]+$")
    local extensions = { jpg=true, jpeg=true, png=true, gif=true }

    if extensions[filext:lower()] then
        return true
    else
        return false
    end
end

utils['latest_files'] = function( directory )
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('find "'..directory..'" -type f ! -name \'*.filepart\' -printf \'%C@ %p\n\'| sort -nr | head -7 | cut -f2- -d" "| sed s:"'..directory..'/"::')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

utils['these_files'] = function( path )
    local files, dirs, images = {}, {}, {}
    for file in lfs.dir( path ) do
        if file ~= "." and file ~= ".." and not string.match(file, ".filepart") then
            if lfs.attributes( path .. file, "mode" ) == "file" then
                if utils.match_image( file ) then
                    table.insert( images, file )
                else
                    table.insert( files, file )
                end
            elseif lfs.attributes( path .. file, "mode" ) == "directory" then
                table.insert( dirs, file )
            end
        end
    end

    table.sort( images )
    table.sort( files )
    table.sort( dirs )

    local stuff = {
        files = files,
        dirs = dirs,
        images = images
    }
    return stuff
end

utils['these_latest'] = function( path )
    -- list last 10 modified files in our directory
    local latest_path, latest_name = {}, {}

    for i, file_path in ipairs( utils.latest_files( path ) ) do
        file_path = file_path:gsub( path, "/" )
        table.insert( latest_path, file_path)

        local temp = ""
        local result = ""
        for i = file_path:len(), 1, -1 do
            if file_path:sub(i,i) ~= "/" then
                temp = temp..file_path:sub(i,i)
            else
                break
            end
        end

        for j = temp:len(), 1, -1 do
            result = result..temp:sub(j,j)
        end

        table.insert( latest_name, result )
    end

    return latest_path, latest_name
end

utils['total_files_dir'] = function( path )
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('find "'..path..'" -type f | wc -l')
    for total in pfile:lines() do
        t[i] = total
        i = i + 1
    end
    pfile:close()
    return t
end

return utils
