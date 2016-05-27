## Database stuff

###
mongoose = require('mongoose')

mongoose.connect('mongodb://localhost/test')
db = mongoose.connection

db.on 'error', (err) ->
  throw err

db.connected = false
db.once 'open', () ->
  console.log "Connected to database!"
  db.connected = true

schemes = {
  user: mongoose.Schema {
    name: String
    password: String
    role: String
  }

  test: mongoose.Schema {
    test: String
  }
}

models = {
  User: mongoose.model 'User', schemes.user

  Test: mongoose.model 'Test', schemes.test
}
###
