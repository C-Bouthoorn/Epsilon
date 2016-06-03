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

    # Dirty handle
    if data.login
      alert "You succesfully logged in!"
    else
      alert "You failed to log in!"
