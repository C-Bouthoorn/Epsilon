module.exports = (server, req, res) ->
  data = req.body

  username = data.username
  password = data.password

  console.log "Logging in '#{username}' with '#{password}'"

  unless server.mdb
    return res.json {
      error: "Database not ready"
    }


  server.models.User.find { username: username }, (users) ->
    if !users? || users.length == 0
      return res.json {
        error: "User not found"
      }

    user = users[0]

    db_password = user.password

    hashsalt(password).verifyAgainst db_password, (err, ok) ->
      if err
        return Server.error err

      res.json {
        login: ok
      }
