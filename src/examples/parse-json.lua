local webify = require("../webify")
local app = webify()

app.addMiddleware(function(req,res) 
  print("Got request for " .. req.getURL())
end)

app.post("/", function(req, res) 
  print(textutils.serialise(req.readAll()))
  if req.json then
    local t = textutils.unserialiseJSON(req.json)
    print(textutils.serialise(t))
  end
  res.write("OK")
  res.close()
end)

app.run(5024)