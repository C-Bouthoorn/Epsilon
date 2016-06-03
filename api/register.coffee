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
    server.error "[RDBERR] Register request but database not ready!"

    res.json {
      err: "REGISTER:INTERNAL_ERROR"
    }

    return

  # Hash password
  hashsalt = require 'password-hash-and-salt'
  hashsalt(password).hash (err, hashpassword) ->
    if err
      server.error err
      return

    # Create new user
    newuser = new server.database.models.User {
      username: username
      password: hashpassword
    }

    # Save to database
    newuser.save (err) ->
      if err
        server.error err
        return

      # Send result
      res.json {
        done: true
      }
