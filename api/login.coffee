module.exports = (server, req, res) ->
  data = req.body

  # Get data
  username = data.username
  password = data.password

  # Check data
  Checker = require './checker'
  return unless Checker.checkUsername(username) && Checker.checkPassword(password)

  # Check database
  unless server.database
    # Database not ready or loaded
    server.error "[LDBERR] Login request but database not ready!"

    res.json {
      err: 'LOGIN:INTERNAL_ERROR'
    }

    return

  # Get user from database
  server.database.models.User.findOne { username: username }, (err, user) ->
    if err
      server.error err
      return

    # User not found
    unless user
      res.json {
        err: 'LOGIN:INVALID_CRED'
      }

      return

    # Get password from database
    db_password = user.password

    # Verify password
    hashsalt = require 'password-hash-and-salt'
    hashsalt(password).verifyAgainst db_password, (err, ok) ->
      if err
        server.error err
        return

      # Send result
      res.json {
        login: ok
      }
