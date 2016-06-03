module.exports = (server, req, res) ->
  data = req.body

  username = data.username
  password = data.password

  Checker = require './checker'
  return unless Checker.checkUsername(username) && Checker.checkPassword(password)

  unless server.database
    server.error "[RDBERR] Register request but database not ready!"

    res.json {
      err: "REGISTER:INTERNAL_ERROR"
    }

    return


  hashsalt = require 'password-hash-and-salt'

  hashsalt(password).hash (err, hashpassword) ->
    if err
      server.error err
      return

    newuser = new server.database.models.User {
      username: username
      password: hashpassword
    }

    newuser.save (err) ->
      if err
        server.error err
        return

      res.json {
        done: true
      }
