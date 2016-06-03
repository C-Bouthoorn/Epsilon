@login = (form, event) ->
  # Prevent default submit action
  event.preventDefault()

  # Get data
  username = $(form).find('#username').val()
  password = $(form).find('#password').val()

  # Clientside checks (To lower server action)
  unless checkUsername username
    return alert "Invalid username"

  unless checkPassword password
    return alert "Invalid password"

  # Prepare
  logindata = {
    username: username
    password: sha256(password)
  }

  # Send API request
  $.post "/api/login", logindata, (data) ->
    console.log data

    if data.login
      location.href = '#/panel'
    else
      alert "You failed to log in!"
