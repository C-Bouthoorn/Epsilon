# File with the requirements of the username and password
# DEV NOTE: Reflect changes in /public_www/scripts/checks.coffee too!


module.exports = {
  checkUsername: (username) ->
    return 4 <= username.length <= 64

  checkPassword: (password) ->
    return 8 <= password.length
}
