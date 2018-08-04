require! {
  osc
  debug
  lodash: { tail, head, map, filter, defaults }
}


toOsc = (args) ->
  getType = (val) ->
    switch val@@
      | String => "s"
      | Number =>
        if Math.round(val) == val then "i" else "f"
      |_ => "unknown"
      
  map args, (val) -> do
    type: getType val
    value: val

fromOsc = (args) -> map args, (.value)

export class OscServer
  options:
    remoteAddress: "127.0.0.1"
    localAddress: "127.0.0.1"
    localPort: 4001
    remotePort: 4000
    metadata: true
    
  (options={}) ->
    @logOsc = debug("osc")
    @logRpc = debug("oscrpc")
    options = defaults(options, @options)
    @logOsc "instantiating listener", options
    @udpPort = new osc.UDPPort options

    @udpPort.open()
    
    @udpPort.on "message", (oscMsg) ~>
      @logOsc "msg <<<", oscMsg
      oscMsg.address = filter oscMsg.address.split('/'), (!= "")

      if head oscMsg.address isnt "query" then return
      apiName = oscMsg.address[1]

      [ callId, ...apiArgs ] = fromOsc oscMsg.args

      @logRpc "got call for #{apiName} with args #{apiArgs} and id #{callId}"
      if @[apiName]?@@ isnt Function then return @logRpc "api call #{apiName} not found"
      result = @[apiName](...apiArgs)
      @logRpc "#{apiName} result: #{result}"
      
      msg = do
        address: "/reply/#{callId}"
        args: toOsc result
        
      @logOsc "msg >>>", oscMsg
      @udpPort.send msg
      

# oscServer = new OscServer()

# oscServer.test = (...args) ->
#   console.log 'test got', args
#   [ 1,2,3]
