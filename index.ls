require! {
  osc
  lodash: { map }
}

udpPort = new osc.UDPPort do
    remoteAddress: "127.0.0.1"
    localAddress: "127.0.0.1"
    localPort: 4001
    remotePort: 4000
    metadata: true

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

udpPort.on "message", (oscMsg) -> 
    console.log "msg in", oscMsg

    if oscMsg.address.slice(0,7) != "/query." then return

    apiName = oscMsg.address.slice(7)
    
    [ callId, ...apiArgs ] = fromOsc oscMsg.args
    console.log 'calling', callId, apiName, ...oscMsg.args

    reply = toOsc(test(...apiArgs))
    console.log 'replying with', ...reply
    udpPort.send do
      address: "/reply.#{callId}"
      args: reply

test = (...args) ->
  return [ 33, "bla", 1.1 ]


udpPort.open()
