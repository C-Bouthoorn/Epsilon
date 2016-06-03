# DEV NOTE: Reflect these two functions in /api/checker.coffee too!
@checkUsername = (username) ->
  return (4 <= username.length <= 64) && /^[a-zA-Z0-9_]+$/.test(username)

@checkPassword = (password) ->
  return 8 <= password.length


# Remove Font Awesome icons from element
@removeIcon = (elem) ->
  return elem
    .removeClass 'fa-check'
    .removeClass 'fa-ban'
    .removeClass 'fa-cog'
    .removeClass 'fa-spin'

# Replace Font Awesome icon from element
@replaceStatusIcon = (elem, newicon) ->
  removeIcon(elem.children '.form-control-feedback').addClass newicon

# Remove bootstrap statusses from element
@removeStatus = (elem) ->
  return elem
    .removeClass 'has-success'
    .removeClass 'has-error'
    .removeClass 'has-warning'

# Replace bootstrap status from element
@replaceStatus = (elem, newstatus) ->
  removeStatus(elem).addClass newstatus

# Set element valid
@setValid = (elem) ->
  elem = elem.closest '.form-group'

  replaceStatus elem, 'has-success'
  replaceStatusIcon elem, 'fa-check'

# Set element invalid
@setInvalid = (elem) ->
  elem = elem.closest '.form-group'

  replaceStatus elem, 'has-error'
  replaceStatusIcon elem, 'fa-ban'

# Set element loading
@setLoading = (elem) ->
  elem = elem.closest '.form-group'

  replaceStatus elem, 'has-warning'
  replaceStatusIcon elem, 'fa-cog fa-spin'

# [shortcut] Set valid/invalid state of element
@setState = (elem, state) ->
  if state # true
    setValid elem
  else # false
    setInvalid elem


@checkto = false

# Validate username from element
@validateUsername = (elem, checkAvailable=false) ->
  return if elem.val() is undefined

  username = elem.val()

  unless checkUsername username
    setInvalid elem
    return


  if checkAvailable
    setLoading elem

    # Remove old timeout
    clearTimeout @checkto  if @checkto

    # Add new timeout for 1 second to let the user finish typing
    # when that's done, request server
    APIcheck = ->
      $.post '/api/register-available', { username: username }, (data) ->
        setState elem, (data.available != false)

    @checkto = setTimeout APIcheck, 1000

  else
    # Username passes check and doesn't need to be checked by API
    # so set valid state
    setValid elem

# Validate password from element
@validatePassword = (elem, checkPassAgain=false) ->
  return if elem.val() is undefined

  password = elem.val()

  setState elem, checkPassword password

  if checkPassAgain
    validatePasswordAgain $('#password-again')

# Validate passwordagain from element
@validatePasswordAgain = (elem) ->
  return if elem.val() is undefined

  password = $('#password').val()
  passwordagain = elem.val()

  setState elem, ( password == passwordagain && checkPassword passwordagain )


# Validate login form
@validateLogin = ->
  validateUsername $('#username')
  validatePassword $('#password')

# Validate register form
@validateRegister = ->
  validateUsername $('#username'), true
  validatePassword $('#password')
  validatePasswordAgain $('#password-again')
