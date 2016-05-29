module.exports = {
  checkUsername: (username) ->
    return 4 <= username.length <= 64

  checkPassword: (password) ->
    return 8 <= password.length
}
