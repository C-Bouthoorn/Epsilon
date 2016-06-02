module.exports = (server, req, res) ->
  res.status(404).json {
    error: "Unknown or invalid API call"
  }
