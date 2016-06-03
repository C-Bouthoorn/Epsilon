module.exports = (server, req, res) ->
  res.status(404).json {
    err: "API:INVALID_CALL"
  }
