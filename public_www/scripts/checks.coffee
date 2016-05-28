@checkUsername = (username) ->
  return 4 <= username.length <= 64

@checkPassword = (password) ->
  return 8 <= password.length


@setValid = (elem) ->
  elem.addClass 'has-success'
  elem.removeClass 'has-error'

  elem.children('.form-control-feedback').addClass 'fa-check'
  elem.children('.form-control-feedback').removeClass 'fa-ban'

@setInvalid = (elem) ->
  elem.removeClass 'has-success'
  elem.addClass 'has-error'

  elem.children('.form-control-feedback').removeClass 'fa-check'
  elem.children('.form-control-feedback').addClass 'fa-ban'


@validateUsername = (elem) ->
  username = $(elem).val()

  if checkUsername username
    setValid $(elem).closest('.form-group')
  else
    setInvalid $(elem).closest('.form-group')

@validatePassword = (elem) ->
  password = $(elem).val()

  if checkPassword password
    setValid $(elem).closest('.form-group')
  else
    setInvalid $(elem).closest('.form-group')

$(document).ready ->
  $('#username').keyup ->
    validateUsername this

  $('#password').keyup ->
    validatePassword this

  $('#password-again').keyup ->
    validatePassword this
