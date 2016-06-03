@register = (form, event) ->
  # Prevent default submit action
  event.preventDefault()

  # Get data
  username = $(form).find('#username').val()
  password = $(form).find('#password').val()
  passwordagain = $(form).find('#password-again').val()

  # Clientside checks (To lower server action)
  unless checkUsername username
    return alert "Invalid username"

  unless checkPassword password
    return alert "Invalid password"

  unless password == passwordagain
    return alert "Passwords aren't equal"

  # Prepare
  registerdata = {
    username: username
    password: sha256(password)
  }

  # Send API request
  $.post "/api/register", registerdata, (data) ->
    console.log data

    # Dirty handle
    if data.done
      alert "You succesfully registered!"
    else
      alert "You failed to register!"
