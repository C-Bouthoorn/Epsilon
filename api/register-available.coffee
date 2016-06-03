module.exports = (server, req, res) ->
  data = req.body

  username = data.username

  Checker = require './checker'
  return unless Checker.checkUsername(username)

  unless server.database
    server.error "[RADBERR] Register request but database not ready!"

    res.json {
      err: "REGISTER_AVAILABLE:INTERNAL_ERROR"
    }

    return

  # Get the amount of users with that username
  server.database.models.User.find({ username: username }).count (err, n) ->
    if err
      server.error err
      return

    res.json {
      available: n == 0
    }
