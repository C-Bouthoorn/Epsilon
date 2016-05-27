module.exports = (server, req, res) ->
  data = req.body

  username = data.username
  password = data.password

  console.log "Registering '#{username}' with '#{password}'"

  unless server.mdb
    return res.json {
      error: "Database not ready"
    }

  hashsalt(password).hash (err, hashpassword) ->
    if err
      return Server.error err


    user = new Server.models.User {
      username: username
      password: hashpassword
    }

    user.save (err) ->
      if err
        return Server.error err

  res.json {
    done: true
  }
