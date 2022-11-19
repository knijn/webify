-- data[1].assets[1].browser_download_url
local apiURL = "http://api.github.com/repos/knijn/webify/releases"
local baseRepoURL = "https://raw.githubusercontent.com/knijn/webify/main"
local args = {...}
local skipcheck = false
if args and args[1] == "y" then
  skipcheck = true
end

local scKey = _G._GIT_API_KEY
if scKey then
  requestData = {
    url = apiURL,
    headers = {["Authorization"] = "token " .. scKey}
  }
  http.request(requestData)
else
  http.request(apiURL) -- when not on switchcraft, use no authentication
end
print("Made request to " .. apiURL)

while true do
  event, url, handle = os.pullEvent()
  if event == "http_failure" then
    error("Failed to download file: " .. handle)
  elseif event == "http_success" then
    print(handle.getResponseCode())
    local data = textutils.unserialiseJSON(handle.readAll())
    local url = data[1].assets[1].browser_download_url
    print("Downloading Webify from: " .. url .. ", is this okay? (n to cancel, anything else to continue)")
    local input = read()
    if not skipcheck and input == keys.n then
      error("Cancelled Installation")
    end
    print("Installing now")
    shell.run("wget " .. url)

    print("Downloading libraries right now")
    shell.run("wget " .. baseRepoURL .. "/src/webify.lua /lib/webify.lua")
    print("Done!!")
    return
  end
end

