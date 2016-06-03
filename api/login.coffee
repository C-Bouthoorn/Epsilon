module.exports = (server, req, res) ->
  data = req.body

  username = data.username
  password = data.password

  Checker = require './checker.coffee'
  return unless Checker.checkUsername(username) && Checker.checkPassword(password)

  unless server.database
    # Database not ready or loaded
    server.error "[LDBERR] Login request but database not ready!"

    res.json {
      err: 'LOGIN:INTERNAL_ERROR'
    }

    return


  hashsalt = require 'password-hash-and-salt'

  server.database.models.User.findOne { username: username }, (err, user) ->
    if err
      server.error err
      return

    unless user
      res.json {
        err: 'LOGIN:INVALID_CRED'
      }

      return

    db_password = user.password

    hashsalt(password).verifyAgainst db_password, (err, ok) ->
      if err
        server.error err
        return

      res.json {
        login: ok
      }
