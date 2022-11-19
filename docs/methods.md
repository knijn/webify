# Methods
Have a look at the example, you'll see the methods provided

```lua
local webify = require("/lib/webify")
local app = webify()

app.addMiddleware(function(req,res) 
  print("Got request for " .. req.getURL())
end)

app.get("/", function(req,res)
    res.write("Hello World!")
    res.close()
end)

app.get("/", function(req,res)
    res.write("OK")
    res.close()
end)

app.run(5024)
```

The objects `req` and `res` are directly forwarded from the CraftOS-PC