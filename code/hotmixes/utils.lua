local lfs = require 'lfs_ffi'
local config = require("lapis.config").get()
local escape = require("lapis.util").escape


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
    request_path = request_uri  .. '/'
else
    request_path = request_uri
end

local data_dir = config.mount
local data_path = data_dir .. request_path
-- setup

local type_image = { jpg=true, jpeg=true, png=true, gif=true }
local type_media = { mp3=true, flac=true, wav=true, mp4=true }
local type_audio = { mp3=true, flac=true, wav=true }
local type_allowed = { jpg=true, jpeg=true, png=true, gif=true, mp3=true, flac=true, wav=true, mp4=true }

local utils =  {}

local function hotesc ( str )
    return escape(str):gsub("%%2f", "/"):gsub("%%2d", "-"):gsub("%%2e", ".")
end

utils['request_path'] = request_path
utils['data_path'] = data_path

-- we want to know if something is an image
utils['match_ext'] = function( file, ext )
    local filext = file:match("[^.]+$")
    if ext[filext:lower()] then
        return true
    else
        return false
    end
end

utils['latest_files'] = function( directory )
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('find -L "'..directory..'" -type f ! -name \'*.filepart\' ! -name \'*.png\' ! -name \'*.jpg\' ! -name \'*.jpeg\' ! -name \'*.gif\' -printf \'%C@ %p\n\'| sort -nr | head -7 | cut -f2- -d" "| sed s:"'..directory..'/"::')
    for filename in pfile:lines() do
        if  utils.match_ext ( filename, type_allowed ) then
            i = i + 1
            t[i] = filename
        end
    end
    pfile:close()
    return t
end

utils['latest_audio'] = function( directory )
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('find -L "'..directory..'" -type f ! -name \'*.filepart\' ! -name \'*.mp4\' ! -name \'*.png\' ! -name \'*.jpg\' ! -name \'*.jpeg\' ! -name \'*.gif\' -printf \'%C@ %p\n\'| sort -nr | head -7 | cut -f2- -d" "| sed s:"'..directory..'/"::')
    for filename in pfile:lines() do
        if  utils.match_ext ( filename, type_audio ) then
            i = i + 1
            t[i] = filename
        end
    end
    pfile:close()
    return t
end

utils['these_files'] = function( path )
    local files, dirs, images = {}, {}, {}
    for file in lfs.dir( path ) do
        if file ~= "." and file ~= ".." and not string.match(file, ".filepart") then
            if lfs.attributes( path .. file, "mode" ) == "file" then
                if utils.match_ext( file, type_image ) then
                    table.insert( images, file )
                elseif utils.match_ext( file, type_media ) then
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

utils['hotesc'] = function( str )
    return hotesc(str)
end

utils['these_latest'] = function( path )
    -- list last 10 modified files in our directory
    local latest_path, latest_name = {}, {}

    for i, file_path in ipairs( utils.latest_files( path ) ) do
        local escpath = hotesc(file_path)
        table.insert( latest_path, escpath )

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


utils['rss_latest'] = function( path )
    local latest_path, latest_name, latest_size, latest_date = {}, {}, {}, {}

    for i, file_path in ipairs( utils.latest_audio( path ) ) do
        local popen = io.popen

        -- get the size of the file
        local psize = popen('wc -c <'..path..'/'..file_path)
        for size in psize:lines() do
            ngx.log(ngx.INFO, size)
            table.insert( latest_size, size)
        end
        psize:close()

        -- get the date of the file
        local pdate = popen('date -d @$(stat -c "%Y" '..path..'/'..file_path..') "+%a, %-d %b %Y %H:%M:%S %Z"')
        for date in pdate:lines() do
            table.insert( latest_date, date )
        end
        pdate:close()

        local escpath = hotesc(file_path)
        table.insert( latest_path, escpath )

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

    return latest_path, latest_name, latest_size, latest_date
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
