module.exports = (server, req, res) ->
  res.status(404).json {
    error: "Invalid API call"
  }
