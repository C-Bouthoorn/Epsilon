Checker = require('./checker.coffee')

module.exports = (server, req, res) ->
  data = req.body

  username = data.username
  password = data.password

  return unless Checker.checkUsername(username) && Checker.checkPassword(password)


  console.log "Logging in '#{username}' with '#{password}'"

  unless server.mdb
    return res.json {
      error: "Database not ready"
    }


  hashsalt = require('password-hash-and-salt')

  server.models.User.findOne { username: username }, (err, user) ->
    if err
      return server.error err

    unless user
      return res.json {
        error: "User not found"
      }

    db_password = user.password

    hashsalt(password).verifyAgainst db_password, (err, ok) ->
      if err
        return server.error err

      res.json {
        login: ok
      }
