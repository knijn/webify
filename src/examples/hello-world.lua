local webify = require("../webify")
local app = webify()

app.addMiddleware(function(req,res) 
  print("Got request from")
end)

app.get("/", function(req,res)
    res.write("Hello World!")
    res.close()
end)

app.run(5024)