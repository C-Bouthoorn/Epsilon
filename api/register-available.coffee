module.exports = (server, req, res) ->
  data = req.body

  # Get data
  username = data.username

  # Check data
  Checker = require './checker'
  return unless Checker.checkUsername(username)

  # Check database
  unless server.database
    server.error "[RADBERR] Register request but database not ready!"

    res.json {
      err: 'REGISTER_AVAILABLE:INTERNAL_ERROR'
    }

    return

  # Get the amount of users with that username
  server.database.models.User.find({ username: username }).count (err, n) ->
    if err
      res.json {
        err: 'REGISTER_AVAILABLE:INTERNAL_ERROR'
      }

      server.error err
      return

    # Send if username is still available
    res.json {
      available: n == 0
    }
