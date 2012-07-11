class Poltergeist.Connection
  constructor: (@owner, @port) ->
    @socket = new WebSocket "ws://localhost:#{@port}/"
    @socket.onmessage = this.commandReceived
    @socket.onclose = -> phantom.exit()

  commandReceived: (message) =>
    @owner.runCommand(JSON.parse(message.data))

  send: (message) ->
    @socket.send(JSON.stringify(message))
