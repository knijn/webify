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
client.stack = {["get"]={},["post"]={},["put"]={},["patch"]={},["delete"]={}}
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

client.put = function(path, callback)
    local t = {}
    t.path = path
    t.callback = callback
    table.insert(client.stack.put,t)
end

client.patch = function(path, callback)
    local t = {}
    t.path = path
    t.callback = callback
    table.insert(client.stack.patch,t)
end

client.delete = function(path, callback)
    local t = {}
    t.path = path
    t.callback = callback
    table.insert(client.stack.delete,t)
end

client.run = function(port)
    http.listen(port, function(req,res) 
        for _,o in pairs(client.middleware) do --middleware
            local req1, res1 = o(req,res)
            if req1 then req = req1 end
            if res1 then res = res1 end
        end
        for _,o in pairs(client.stack[string.lower(req.getMethod())]) do -- check for get
            if not o.path or not o.callback then return end
            if startsWith(req.getURL(),o.path) then
                local output = o.callback(req,res)
                if pcall(function() res.write("") end) and output then
                    res.write(output)
                    res.close()
                else
                    -- it was closed, nothing to do here
                end
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
        req.body = body
    end

    client.addMiddleware(addArgs)
    client.addMiddleware(addJSON)
    return client
end

return webify