# For all coffeescript files we're going to import
require 'coffee-script'

# The ExpressJS base
express = require 'express'
app = express()

# The Server object we'll put all important stuff in to send to the API
# and to keep everything in place
Server = {}


## Helping functions

# rerequire a module -- remove from cache and re-require from file
# Comes in handy in development builds when custom modules are often changing
rerequire = (modpath) ->
  path = require 'path'

  # Remove from cache
  delete require.cache[path.resolve modpath]

  # Reload file
  return require modpath


## Load configuration

CSON = require 'cson'
Server.config = CSON.parseFile 'config.cson'


## Logger functions

Server.logger = false

# Log a normal message
Server.log = (msg) ->
  if Server.logger
    # Use logger if enabled
    Server.logger.log msg
  else
    # fallback: Use console if we don't have a logger
    console.log msg

# Log an error
Server.error = (err) ->
  if Server.logger
    # Use logger if enabled
    Server.logger.error err
  else
    # fallback: Use console if we don't have a logger
    console.error err

# Prepare logger
if Server.config.log && Server.config.log.enabled
  Logger = require './logger'
  Server.logger = new Logger(Server.config.log)

  # Redirect server logs to logger
  app.use (err, req, res, next) ->
    Server.logger.errorlogger(err, req, res, next)

  app.use (req, res, next) ->
    Server.logger.accesslogger(req, res, next)

  Server.log "Log enabled"


## Database functions

Server.database = false

# Prepare database
if Server.config.database && Server.config.database.enabled
  mongoose = require 'mongoose'

  Server.database = {}

  # Connect
  mongoose.connect Server.config.database.url
  Server.database.conn = mongoose.connection

  # Add log listeners
  Server.database.conn.on 'error', ->
    # TODO: Specify error
    Server.error "Database error"

  Server.database.conn.once 'open', ->
    Server.log "Database connected"

  # Schemas
  Server.database.schemas = {
    User: mongoose.Schema {
      username: String
      password: String
    }
  }

  # Models
  Server.database.models = {
    User: mongoose.model 'User', Server.database.schemas.User
  }


## Load middlewares

# Load POST message parser
bodyParser = require 'body-parser'
app.use bodyParser.json()
app.use bodyParser.urlencoded { extended: true }

# Load session
session = require 'express-session'
mongostore = require('connect-mongo')(session)

# Use existing connection for database
if Server.database
  store = new mongostore {
    mongooseConnection: Server.database.conn
  }
else
  store = new mongostore()

app.use session {
  name: 'SESSION_ID'
  resave: false
  saveUninitialized: true
  secret: 'Epsilon'
  store: store

  cookie: {
    secure: 'auto'
  }
}

## Prepare API calls

# DEV NOTE: Change to dynamic loading
app.all '/api/panel/:func?', (req, res) ->

  func = req.params.func

  if func == 'get'
    # DEV NOTE: Might be easy to DoS. Load dir structure once (in production)!
    api = rerequire('./api/panel/' + req.body.get)

    api(Server, req, res)

  else
    res.status(500).json {
      err: 'PANEL:INVALID_REQUEST'
    }


app.all '/api/:func?', (req, res) ->
  func = req.params.func

  # Check if path is valid
  unless /^[a-zA-Z0-9\-]+$/.test(func)
    # Invalid call!
    return

  fs = require 'fs'

  # Check if file exists
  # DEV NOTE: Might be easy to DoS. Load dir structure once (in production)!
  fs.access "./api/#{func}.coffee", fs.F_OK & fs.R_OK, (err) ->
    # DEV NOTE: Using rerequire() because this is a development build
    #           Remove from production

    if err
      # Send error when invalid
      api = rerequire('./api/error')
    else
      api = rerequire('./api/' + func)

    # Call API
    api(Server, req, res)

## Prepare servers

# Test if server is running
app.get '/OK', (req, res) -> res.send "OK"

# Load root folder statically
app.use '/', express.static "#{Server.config.wwwroot}/", {
  extensions: [ 'html', 'css', 'coffee', 'js' ]
}

# Prepare HTTPS server
if Server.config.https && Server.config.https.enabled
  fs    = require 'fs'
  https = require 'https'

  httpsserver = https.createServer {
    key:  fs.readFileSync Server.config.https.pem.key,  'utf8'
    cert: fs.readFileSync Server.config.https.pem.cert, 'utf8'
    passphrase: Server.config.https.pem.passphrase
  }, app



## Start servers

# Start HTTP server
if Server.config.http && Server.config.http.enabled
  app.listen (Server.config.http.port || 80), ->
    Server.log "HTTP server is now listening on port #{Server.config.http.port}"

# Start HTTPS server
if Server.config.https && Server.config.https.enabled
  httpsserver.listen (Server.config.https.port || 443), ->
    Server.log "HTTPS server is now listening on port #{Server.config.https.port}"

# Drop back user
if Server.config.dropbackuser && Server.config.dropbackuser.enabled
  oldgid = process.getgid()
  olduid = process.getuid()

  try
    process.setgid Server.config.dropbackuser.gid
    process.setuid Server.config.dropbackuser.uid

    Server.log "Dropped back permissions from '#{olduid}:#{oldgid}' to '#{uid}:#{gid}'"
  catch err
    Server.error "Failed to drop back permissions! Running as '#{olduid}:#{oldgid}'"
    Server.error err
else
  Server.log "Didn't drop back permissions; running as '#{olduid}:#{oldgid}'"
