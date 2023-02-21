local function startsWith(string,start)
    return string.sub(string,1,string.len(start))==start
end
 
local function split(string)
    local split = {}
    local n = 0
    for str in string.gmatch(string, "([^%/]+)") do
        n = n + 1
        split[n] = str
    end
    return split
end

local client = {}
client.stack = {["get"]={},["post"]={}}
client.middleware = {}

client.addMiddleware = function(func) 
    table.insert(client.middleware,func)
end
client.get = function(path, callback)
    local t = {}
    t.path = path
    t.callback = callback
    table.insert(client.stack.get,t)
end

client.post = function(path, callback)
    local t = {}
    t.path = path
    t.callback = callback
    table.insert(client.stack.post,t)
end

client.run = function(port)
    http.listen(port, function(req,res) 
        for _,o in pairs(client.middleware) do --middleware
            local req1, res1 = o(req,res)
            if req1 then req = req1 end
            if res1 then res = res1 end
        end
        for _,o in pairs(client.stack.post) do -- check for post
            if not o.path or not o.callback then return end
            if startsWith(req.getURL(),o.path) then
                o.callback(req,res)
                return
            end
        end
        for _,o in pairs(client.stack.get) do -- check for get
            if not o.path or not o.callback then return end
            if startsWith(req.getURL(),o.path) then
                o.callback(req,res)
                return
            end
        end
    end)
end

function webify()
    local function addArgs(req,res) 
        local t = split(req.getURL())
        req.args = t
    end
    local function addJSON(req,res)
        local body = req.readAll()
        req.readAll = function() return body end
        req.json = textutils.serialiseJSON(body)
    end

    client.addMiddleware(addArgs)
    client.addMiddleware(addJSON)
    return client
end

return webify