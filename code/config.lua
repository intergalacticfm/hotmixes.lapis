local config = require("lapis.config")
config({"development", "production"}, {
  host = "Video Hotmix Archive",
  greeting = "Welcome, We Are Your Friends",
  mount = "/mnt/data/",
})

config("production", {
  greeting = "nothing here yet",
  logging = {
    queries = false
  }
})
