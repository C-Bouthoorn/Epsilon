module.exports = (server, req, res) ->
  data = req.body

  username = data.username

  Checker = require('./checker')
  return unless Checker.checkUsername(username)

  server.models.User.find({ username: username }).count (err, n) ->
    if err
      return server.error err

    res.json {
      available: n == 0
    }
