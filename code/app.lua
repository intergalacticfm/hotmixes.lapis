local lapis = require("lapis")

local app = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

local Roothandler = require("handlers.roothandler")
local Latesthandler = require("handlers.latesthandler")
local RSShandler = require("handlers.RSShandler")

local page_titles = {}

if string.find(ngx.var.host, "panamaracing.club") then
    page_titles = {
        name = "Panama Racing Club Archive",
        url = "panamaracing.club",
        path = "panamaracing.club",
        css = "panamaracing.css",
        header = "panamaracing.club_header.png",
        feed = "panamaracing.club"
    }
elseif string.find(ngx.var.host, "videohotmix.net") then
    page_titles = {
        name = "Hotmix Vault",
        url = "videohotmix.net",
        path = "videohotmix.net",
        css = "videohotmix.css",
        header = "videohotmix.net-logo.png",
        feed = "videohotmix"
    }
elseif string.find(ngx.var.host, "hotmixxx.com") then
    page_titles = {
        name = "Hotmix Vault",
        url = "hotmixxx.com",
        path = "videohotmix.net",
        css = "videohotmix.css",
        header = "videohotmix.net-logo.png",
        feed = "hotmixxx"
    }

elseif string.find(ngx.var.host, "hotmixes.net") then
    page_titles = {
        name = "Hotmix Vault",
        url = "hotmixes.net",
        path = "videohotmix.net",
        css = "videohotmix.css",
        header = "videohotmix.net-logo.png",
        feed = "hotmixes"
    }
else
    page_titles = {
        name = "Local Test Archive",
        url = "localhost"
    }
end

app:get("/", function(self)
    self.titles = page_titles
    return Roothandler(self)
end)

app:get("/latest.json", function(self)
    self.titles = page_titles
    return Latesthandler(self)
end)

app:get("/latest.rss", function(self)
    self.titles = page_titles
    return RSShandler(self)
end)

app:get("/*", function(self)
    self.titles = page_titles
    return Roothandler(self)
end)


return app
