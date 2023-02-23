local webify = require("../webify")
local app = webify()

app.addMiddleware(function(req,res) 
  print("Got request for " .. req.getURL())
end)

app.get("/", function(req,res)
  return "Hello World!"
end)

app.post("/", function(req,res)
    return "Hello World!"
end)

app.put("/", function(req,res)
    return "Hello World!"
end)

app.patch("/", function(req,res)
    return "Hello World!"
 end)

app.delete("/", function(req,res)
    return "Hello World!"
end)

app.run(5024)