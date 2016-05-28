@login = (form, event) ->
  event.preventDefault()

  username = $(form).find('#username').val()
  password = $(form).find('#password').val()

  logindata = {
    username: username
    password: sha256(password)
  }

  unless checkUsername username
    return alert "Invalid username"

  unless checkPassword password
    return alert "Invalid password"

  $.post "/api/login", logindata, (data) ->
    console.log data

    if data.login
      alert "You succesfully logged in!"
    else
      alert "You failed to log in!"
