@register = (form, event) ->
  event.preventDefault()

  username = $(form).find('#username').val()
  password = $(form).find('#password').val()
  passwordagain = $(form).find('#password-again').val()

  unless checkUsername username
    return alert "Invalid username"

  unless checkPassword password
    return alert "Invalid password"

  unless password == passwordagain
    return alert "Passwords aren't equal"

  registerdata = {
    username: username
    password: sha256(password)
  }

  $.post "/api/register", registerdata, (data) ->
    console.log data

    if data.done
      alert "You succesfully registered!"
    else
      alert "You failed to register!"
