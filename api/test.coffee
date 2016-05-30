module.exports = (server, req, res) ->
  res.status(200).json {
    OK: true
    DBOK: server.mdb != false
  }
