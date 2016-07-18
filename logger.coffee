Logger = (config) ->
  this.config = config

  # Set required defaults
  unless this.config.timeformat
    # Default is ISO 8601
    this.config.timeformat = "YYYY-MM-DD[T]HH:MM:SSZ"

  return this


# Append string to file
append = (file, data) ->
  fs = require 'fs'

  fs.appendFile file, "#{data}\n", (err) ->

    if err
      # Can't use Logger here as that might (and will) result in recursing errors
      console.error err


Logger.prototype.gettime = ->
  moment = require 'moment'

  return moment().format this.config.timeformat


Logger.prototype.accesslogger = (req, res, next) ->
  return unless this.config.access && this.config.access.enabled

  # DEV NOTE: We're evalutating everything, even when it's not needed
  #           We should only evaluate (and require modules) when needed

  ip = req.connection.remoteAddress
  method = req.method
  url = req.path
  time = this.gettime()
  name = false

  # Skip disabled IPs
  if ip in this.config.access.disable
    next()
    return

  # Get name of friend
  if this.config.access.friends && this.config.access.friends[ip]?
    name = this.config.access.friends[ip]

  useragent = require 'useragent'
  ua = req.get('User-Agent')
  pua = useragent.parse(ua).toString()  # Parsed UserAgent

  format = this.config.access.format

  data = format
    .replace /:time:/gi, time
    .replace /:ip:/gi, ip
    .replace /:ip4:/gi, ip.replace(/^::ffff:/, '')  # Remove IPv4 prefix
    .replace /:name:/gi, if name then name else "unknown"
    .replace /:name\?:/gi, if name then name else ""  # Don't show "unknown" when name isn't known
    .replace /:method:/gi, method
    .replace /:url:/gi, url
    .replace /:puseragent:/gi, pua


  if this.config.access.file
    append this.config.access.file, data

  if this.config.access.stdout
    console.log data

  if this.config.access.stderr
    console.error data

  next()


Logger.prototype.errorlogger = (err, req, res, next) ->
  return unless this.config.error && this.config.error.enabled

  if this.config.error.file
    append this.config.error.file, err

  if this.config.error.stdout
    console.log err
  if this.config.error.stderr
    console.error err

  if res.headersSent
    next(err)
    return

  res.status(500).json {
    err: 'UNKNOWN:UNKNOWN'
  }



Logger.prototype.log = (msg) ->
  return unless this.config.server && this.config.server.enabled

  time = this.gettime()

  if this.config.server.file
    append this.config.server.file, "[#{time}] #{msg}"

  if this.config.server.stdout
    console.log "[#{time}] #{msg}"
  if this.config.server.stderr
    console.error "[#{time}] #{msg}"


Logger.prototype.error = (err) ->
  return unless this.config.error && this.config.error.enabled

  time = this.gettime()

  if this.config.error.file
    append this.config.error.file, "[#{time}] #{err}"

  if this.config.error.stdout
    console.log "[#{time}] #{err}"
  if this.config.error.stderr
    console.error "[#{time}] #{err}"


module.exports = Logger
