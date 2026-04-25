local lapis = require("lapis")
local config = require("lapis.config").get()
local json_params = require("lapis.application").json_params

local app = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

local autoload = require("lapis.util").autoload
local handlers = autoload("handlers")

local page_titles = {}

if string.find(ngx.var.host, "panamaracing.club") then
    page_titles = {
        name = "Panama Racing Club Archive",
        url = "panamaracing.club",
        css = "panamaracing.css",
        header = "panamaracing.club_header.png"
    }
elseif string.find(ngx.var.host, "videohotmix.net") then
    page_titles = {
        name = "Hotmix Video Archive",
        url = "videohotmix.net",
        css = "videohotmix.css",
        header = "videohotmix.net-logo.png"
    }
elseif string.find(ngx.var.host, "hotmixxx.com") then
    page_titles = {
        name = "Hotmix Video Archive",
        url = "videohotmix.net",
        css = "videohotmix.css",
        header = "videohotmix.net-logo.png"
    }
else
    page_titles = {
        name = "Local Test Archive",
        url = "localhost"
    }
end

app:get("/", function(self)
    self.titles = page_titles
    return handlers.Roothandler(self)
end)

app:get("/latest.json", function(self)
    self.titles = page_titles
    return handlers.Latesthandler(self)
end)

app:get("/latest.rss", function(self)
    self.titles = page_titles
    return handlers.RSShandler(self)
end)

app:get("/*", function(self)
    self.titles = page_titles
    return handlers.Roothandler(self)
end)


return app
