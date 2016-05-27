fs = require('fs')
moment = require('moment')
useragent = require('useragent')

Logger = (config) ->
  this.config = config
  return


# Append string to file
append = (file, data) ->
  fs.appendFile file, "#{data}\n", (err) ->
    if err
      throw err


Logger.prototype.accesslogger = (req, res, next) ->
  ip = req.connection.remoteAddress

  if ip in this.config.access.disable
    next()
    return

  time = moment().format this.config.timeformat

  name = "unknown"
  if this.config.access.friends[ip]?
    name = this.config.access.friends[ip]

  method = req.method
  url = req.path
  ua = useragent.parse(req.get('User-Agent')).toString()

  # ":ip: - :method: :url: || :useragent:"
  format = this.config.access.format

  data = format
    .replace /:time:/gi, time
    .replace /:ip:/gi, ip.replace(/^::ffff:/, '')
    .replace /:name:/gi, name
    .replace /:method:/gi, method
    .replace /:url:/gi, url
    .replace /:useragent:/gi, ua


  if this.config.access.file
    append this.config.access.file, data

  if this.config.access.stdout
    console.log data

  next()


Logger.prototype.errorlogger = (err, req, res, next) ->
  if res.headersSent
    return next(err)

  res.status(500).json({error: "Unknown error. We're sorry"})

  if this.config.error.file
    append this.config.error.file, err

  if this.config.error.stdout
    console.log err
  if this.config.error.stderr
    console.error err



Logger.prototype.log = (msg) ->
  if this.config.server.file
    time = moment().format this.config.timeformat
    append this.config.server.file, "[#{time}] #{msg}"

  if this.config.server.stdout
    console.log msg
  if this.config.server.stderr
    console.error msg


Logger.prototype.error = (err) ->
  if this.config.error.file
    time = moment().format this.config.timeformat
    append this.config.error.file, "[#{time}] #{err}"

  if this.config.error.stdout
    console.log err
  if this.config.error.stderr
    console.error err


module.exports = Logger
