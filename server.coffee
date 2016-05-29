express = require('express')
CoffeeScript = require('coffee-script')
CSON = require('cson')
path = require('path')
util = require('util')
mongoose = require('mongoose')
bodyParser = require('body-parser')
https = require('https')
fs = require('fs')


app = express()
Server = {}

## Just some functions
rerequire = (modpath) ->
  delete require.cache[path.resolve modpath]
  return require modpath


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

# Set up HTTPS server
if Server.config.https && Server.config.https.enabled
  httpsserver = https.createServer {
    key: fs.readFileSync(Server.config.https.pem.key, 'utf8')
    cert: fs.readFileSync(Server.config.https.pem.cert, 'utf8')
    passphrase: Server.config.https.pem.passphrase
  }, app

## API stuff

app.all '/api/:func?', (req, res) ->

  api = require('./api/index')

  switch req.params.func

    # NOTE: Using rerequire() because this is a development build
    #       don't forget to remove in production

    when 'test'
      api = rerequire('./api/test')
    when 'login'
      api = rerequire('./api/login')
    when 'register'
      api = rerequire('./api/register')
    when 'register-available'
      api = rerequire('./api/register-available')

  api(Server, req, res)


if Server.config.http && Server.config.http.enabled
  app.listen (Server.config.http.port || 80), ->
    Server.log "HTTP server is now listening on port #{Server.config.http.port}"

if Server.config.https && Server.config.https.enabled
  httpsserver.listen (Server.config.https.port || 443), ->
    Server.log "HTTPS server is now listening on port #{Server.config.https.port}"
