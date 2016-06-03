module.exports = (server, req, res) ->
  res.status(500).json {
    err: "API:INVALID_CALL"
  }
