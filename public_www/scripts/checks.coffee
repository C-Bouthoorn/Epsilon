@checkto = false

@checkUsername = (username) ->
  return 4 <= username.length <= 64

@checkPassword = (password) ->
  return 8 <= password.length


@removeFaClasses = (elem) ->
  elem.removeClass 'fa-check'
  elem.removeClass 'fa-ban'
  elem.removeClass 'fa-cog'
  elem.removeClass 'fa-spin'

  return elem

@removeStatusClasses = (elem) ->
  elem.removeClass 'has-success'
  elem.removeClass 'has-error'
  elem.removeClass 'has-warning'

  return elem


@setValid = (elem) ->
  elem = elem.closest('.form-group')

  removeStatusClasses(elem).addClass 'has-success'
  removeFaClasses(elem.children '.form-control-feedback').addClass 'fa-check'


@setInvalid = (elem) ->
  elem = elem.closest('.form-group')

  removeStatusClasses(elem).addClass 'has-error'
  removeFaClasses(elem.children '.form-control-feedback').addClass 'fa-ban'

@setLoading = (elem) ->
  elem = elem.closest('.form-group')

  removeStatusClasses(elem).addClass 'has-warning'
  removeFaClasses(elem.children '.form-control-feedback').addClass 'fa-cog fa-spin'


@validateUsername = (elem, checkAvailable=false) ->
  return if elem.val() is undefined

  username = elem.val()

  validate = (valid) ->
    if valid
      setValid elem
    else
      setInvalid elem


  unless checkUsername username
    validate false
    return


  if checkAvailable
    setLoading elem

    if @checkto
      clearTimeout @checkto

    # Always wait 1 second to let the user finish typing
    @checkto = setTimeout (->
      $.post '/api/register-available', { username: username }, (data) ->
        validate(data.available isnt false)
    ), 1000
  else
    validate true

@validatePassword = (elem, checkagain=false) ->
  return if elem.val() is undefined

  password = elem.val()

  if checkPassword password
    setValid elem
  else
    setInvalid elem

  if checkagain
    validatePasswordAgain $('#password-again')

@validatePasswordAgain = (elem) ->
  return if elem.val() is undefined

  password = elem.val()

  if ( password == $('#password').val() ) && checkPassword password
    setValid elem
  else
    setInvalid elem


@validateLogin = ->
  validateUsername $('#username')
  validatePassword $('#password')

@validateRegister = ->
  validateUsername $('#username'), true
  validatePassword $('#password')
  validatePasswordAgain $('#password-again')
