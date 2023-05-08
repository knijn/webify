---------
-- Webify is an unopinionated web framework, based on express.js syntax
-- @module webify
-- @author EmmaKnijn
-- @license MIT

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

---- Adds a middleware,
-- they allow you to make changes to the req and res objects before they reach your handlers
-- @param func A function to call
-- @return nil
client.addMiddleware = function(func) 
    table.insert(client.middleware,func)
end

---- Adds a GET request to the stack
-- The callback function will be ran on a matching GET request
-- @param path The path that will be checked against, "/" by default
-- @param func A callback function
-- @return nil
client.get = function(path, callback)
    local t = {}
    t.path = path or "/"
    t.callback = callback
    table.insert(client.stack.get,t)
end

---- Adds a POST request to the stack
-- The callback function will be ran on a matching POST request
-- @param path The path that will be checked against, "/" by default
-- @param func A callback function
-- @return nil
client.post = function(path, callback)
    local t = {}
    t.path = path or "/"
    t.callback = callback
    table.insert(client.stack.post,t)
end

---- Adds a PUT  request to the stack
-- The callback function will be ran on a matching PUT request
-- @param path The path that will be checked against, "/" by default
-- @param func A callback function
-- @return nil
client.put = function(path, callback)
    local t = {}
    t.path = path or "/"
    t.callback = callback
    table.insert(client.stack.put,t)
end

---- Adds a PATCH request to the stack
-- The callback function will be ran on a matching PATCH request
-- @param path The path that will be checked against, "/" by default
-- @param func A callback function
-- @return nil
client.patch = function(path, callback)
    local t = {}
    t.path = path or "/"
    t.callback = callback
    table.insert(client.stack.patch,t)
end

---- Adds a DELETE request to the stack
-- The callback function will be ran on a matching DELETE request
-- @param path The path that will be checked against, "/" by default
-- @param func A callback function
-- @return nil
client.delete = function(path, callback)
    local t = {}
    t.path = path or "/"
    t.callback = callback
    table.insert(client.stack.delete,t)
end

---- Runs the listener
-- The callback function will be ran on a matching DELETE request
-- @param num
-- @return nil
client.run = function(port)
    http.listen(port, function(req,res) 
        for _,o in pairs(client.middleware) do --middleware
            local req1, res1 = o(req,res)
            if req1 then req = req1 end
            if res1 then res = res1 end
        end
        if client.stack[string.lower(req.getMethod())] then
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
        end
    end)
end

---- Creates a client object
-- @return tbl The client object

function webify()
    local function addArgs(req,res) 
        local t = split(req.getURL())
        req.args = t
    end
    local function addJSON(req,res)
        local body = req.readAll()
        req.readAll = function() return body end
        req.json = textutils.unserialiseJSON(body)
        req.body = body
    end

    client.addMiddleware(addArgs)
    client.addMiddleware(addJSON)
    return client
end

return webify
