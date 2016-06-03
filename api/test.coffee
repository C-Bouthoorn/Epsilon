module.exports = (server, req, res) ->
  res.status(200).json {
    OK: true

    # Check if database is enabled
    DBOK: server.database != false
  }
