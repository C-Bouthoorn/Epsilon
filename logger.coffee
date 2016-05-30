Logger = (config) ->
  this.config = config

  # Set timeformat if false
  unless this.config.timeformat
    # Default is ISO 8601
    this.config.timeformat = "YYYY-MM-DD[T]HH:MM:SSZ"

  return this


# Append string to file
append = (file, data) ->
  # DEV NOTE: Maybe open file once and append to it later?
  #           I don't know how NodeJS handles this internally

  fs = require('fs')
  fs.appendFile file, "#{data}\n", (err) ->

    if err
      # DEV NOTE: ehm?
      return ( new Logger({}) ).error err


moment = require('moment')

Logger.prototype.accesslogger = (req, res, next) ->
  return unless this.config.access && this.config.access.enabled

  # DEV NOTE: We're evalutating everything, even when it's not needed
  #           We should only evaluate (and require modules) when needed

  ip = req.connection.remoteAddress
  method = req.method
  url = req.path
  time = moment().format this.config.timeformat
  name = false

  if ip in this.config.access.disable
    next()
    return


  if this.config.access.friends && this.config.access.friends[ip]?
    name = this.config.access.friends[ip]

  useragent = require('useragent')
  ua = useragent.parse( req.get('User-Agent') ).toString()

  format = this.config.access.format

  data = format
    .replace /:time:/gi, time
    .replace /:ip:/gi, ip
    .replace /:ip-:/gi, ip.replace(/^::ffff:/, '')
    .replace /:name:/gi, if name then name else "unknown"
    .replace /:name\?:/gi, if name then name else ""
    .replace /:method:/gi, method
    .replace /:url:/gi, url
    .replace /:useragent:/gi, ua


  if this.config.access.file
    append this.config.access.file, data

  if this.config.access.stdout
    console.log data

  if this.config.access.stderr
    console.error data

  next()


Logger.prototype.errorlogger = (err, req, res, next) ->
  if res.headersSent
    return next(err)

  res.status(500).json {
    error: "Unknown error. We're sorry"
  }

  return unless this.config.error && this.config.error.enabled

  if this.config.error.file
    append this.config.error.file, err

  if this.config.error.stdout
    console.log err
  if this.config.error.stderr
    console.error err



Logger.prototype.log = (msg) ->
  return unless this.config.server && this.config.server.enabled

  time = moment().format this.config.timeformat

  if this.config.server.file
    time = moment().format this.config.timeformat
    append this.config.server.file, "[#{time}] #{msg}"

  if this.config.server.stdout
    console.log "[#{time}] #{msg}"
  if this.config.server.stderr
    console.error "[#{time}] #{msg}"


Logger.prototype.error = (err) ->
  return unless this.config.error && this.config.error.enabled

  if this.config.error.file
    time = moment().format this.config.timeformat
    append this.config.error.file, "[#{time}] #{err}"

  if this.config.error.stdout
    console.log "[#{time}] #{err}"
  if this.config.error.stderr
    console.error "[#{time}] #{err}"


module.exports = Logger
