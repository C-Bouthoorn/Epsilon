# The ExpressJS base
express = require 'express'
app = express()

# The Server object we'll put all important stuff in to send to the API
# and to keep everything organised
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
  # Load logger with config
  Logger = require './logger'
  Server.logger = new Logger(Server.config.log)

  # Redirect server logs to logger
  app.use (err, req, res, next) ->
    Server.logger.errorlogger(err, req, res, next)

  app.use (req, res, next) ->
    Server.logger.accesslogger(req, res, next)

  Server.log "Log enabled"


## Helper functions

# Use rerequire if running on development build, require otherwise
# rerequire reloads the API file every time it's used
reqfunc = require
if Server.config.dev
  reqfunc = rerequire


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
  Server.database.conn.on 'error', (err) ->
    Server.error "Database error"
    Server.error err

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


if Server.database
  # Use existing connection for database
  store = new mongostore {
    mongooseConnection: Server.database.conn
  }
else
  # Create new connection for database
  store = new mongostore()

app.use session {
  name: 'SESSION_ID'
  resave: false
  saveUninitialized: true
  secret: 'Epsilon'  # TODO: Stronger secret
  store: store

  cookie: {
    secure: 'auto'
  }
}

## Prepare API calls

app.all '/api/panel/:func?', (req, res) ->

  func = req.params.func

  # TODO: Make more static
  if func == 'get'
    # TODO: Might be easy to DoS. Load dir structure once in production!
    api = reqfunc('./api/panel/' + req.body.get)

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
  # TODO: Might be easy to DoS. Load dir structure once in production!
  fs.access "./api/#{func}.coffee", fs.F_OK & fs.R_OK, (err) ->

    if err
      # Send error when invalid
      api = reqfunc('./api/error')
    else
      api = reqfunc('./api/' + func)

    # Call API
    api(Server, req, res)

## Prepare servers

# External test if server is running
app.get '/OK', (req, res) -> res.send "OK"


# Get default extensions
if Server.config.dev
  # Dev build shouldn't use minified versions
  extensions = [ 'html', 'css', 'js' ]
else
  # Keep normal extensions as backup
  extensions = [ 'min.html', 'min.css', 'min.js', 'html', 'css', 'js' ]

# Load root folder statically
app.use '/', express.static "#{Server.config.wwwroot}/", {
  extensions: extensions
}

# Prepare HTTPS server
if Server.config.https && Server.config.https.enabled
  fs    = require 'fs'
  https = require 'https'

  httpsserver = https.createServer {
    key:  fs.readFileSync Server.config.https.pem.key,   'utf8'
    cert: fs.readFileSync Server.config.https.pem.cert,  'utf8'
    ca:   ( if Server.config.https.pem.chain then fs.readFileSync(Server.config.https.pem.chain, 'utf8') else undefined )
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


## Final tasks

# Drop back user
if Server.config.dropbackuser && Server.config.dropbackuser.enabled
  gid = Server.config.dropbackuser.gid
  uid = Server.config.dropbackuser.uid
  
  oldgid = process.getgid()
  olduid = process.getuid()

  # Get readable names from ID's
  userid = require('userid')
  oldname = userid.username(olduid)
  oldgroup = userid.groupname(oldgid)

  if ( gid == oldgid || gid == oldgroup ) && ( uid == olduid || uid == oldname )
    # Nothing to drop back
    Server.log "Didn't drop back permissions; running as '#{oldname}:#{oldgroup}'"

  else
    process.setgid gid
    process.setuid uid

    Server.log "Dropped back permissions from '#{oldname}:#{oldgroup}' to '#{uid}:#{gid}'"

else
  Server.log "Didn't drop back permissions; running as '#{oldname}:#{oldgroup}'"


# Preload API when no development build
unless Server.config.dev
  # TODO: Dynamic
  for api in [ 'checker', 'error', 'login', 'register-available', 'register', 'test' ]
    require('./api/' + api)
