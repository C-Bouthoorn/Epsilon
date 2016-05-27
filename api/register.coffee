module.exports = (server, req, res) ->
  data = req.body

  username = data.username
  password = data.password

  console.log "Registering '#{username}' with '#{password}'"

  unless server.mdb
    return res.json {
      error: "Database not ready"
    }


  hashsalt = require('password-hash-and-salt')

  hashsalt(password).hash (err, hashpassword) ->
    if err
      return server.error err


    user = new server.models.User {
      username: username
      password: hashpassword
    }

    user.save (err) ->
      if err
        return server.error err

      res.json {
        done: true
      }
