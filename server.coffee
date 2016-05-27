express = require('express')
CoffeeScript = require('coffee-script')
CSON = require('cson')
path = require('path')
util = require('util')
mongoose = require('mongoose')
bodyParser = require('body-parser')


app = express()
Server = {}

## Config stuff

Server.config = CSON.parseFile('config.cson')


## Logging stuff
Server.logger = false

Server.log = (msg) ->
  if Server.logger
    # Use logger if enabled
    Server.logger.log msg
  else
    # Use console if we don't have a logger
    console.log msg


Server.error = (err) ->
  if Server.logger
    # Use logger if enabled
    Server.logger.error err
  else
    # Use console if we don't have a logger
    console.error err


if Server.config.log && Server.config.log.enabled
  Logger = require('./logger.coffee')
  Server.logger = new Logger(Server.config.log)

  app.use (err, req, res, next) ->
    Server.logger.errorlogger(err, req, res, next)

  app.use (req, res, next) ->
    Server.logger.accesslogger(req, res, next)

  Server.log "Log enabled"

## Database stuff

Server.mdb = false
if Server.config.database && Server.config.database.enabled
  mongoose.connect Server.config.database.url
  Server.mdb = mongoose.connection

  Server.mdb.on 'error', ->
    Server.error "Database error"

  Server.mdb.once 'open', ->
    Server.log "Database connected"

  # Create schemas and models
  Server.schemas = {
    User: mongoose.Schema {
      username: String
      password: String
    }
  }

  Server.models = {
    User: mongoose.model 'User', Server.schemas.User
  }


## Server stuff

app.use bodyParser.json()
app.use bodyParser.urlencoded({
  extended: true
})

app.use '/', express.static "#{Server.config.wwwroot}/", {
  extensions: [ '.html' ]
}

## API stuff

app.all '/api/:func?', (req, res) ->

  api = require('./api/index')

  switch req.params.func
    when 'test'
      api = require('./api/test')
    when 'login'
      api = require('./api/login')
    when 'register'
      api = require('./api/register')

  api(Server, req, res)



app.listen (Server.config.port || 80), ->
  Server.log "Server is now listening on port #{Server.config.port}"
