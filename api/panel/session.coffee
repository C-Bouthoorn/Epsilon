module.exports = (server, req, res) ->
  res.json {
    id: req.session.id
  }
