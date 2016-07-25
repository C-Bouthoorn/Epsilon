module.exports = (server, req, res) ->
  data = req._POST

  meth = data.meth || 'GET'
  prot = data.prot || 'http'
  host = data.host || undefined
  port = data.port || 80
  path = data.path || '/'


  unless meth == 'GET' or meth == 'POST'
    res.status(500).end "No 1"
    return

  unless prot == 'http' or prot == 'https'
    res.status(500).end "No 2"
    return

  if host is undefined || /^(192|127|local)/.test host
    res.status(500).end "No 3"
    return

  http = require 'http'
  httpreq = http.request { method: meth, protocol: prot, host: host, port: port, path: path }, (httpres) ->
    # Send through headers
    for own k,v of httpres.headers
      res.setHeader k, v

    # Send through data
    httpres.on 'data', (chunk) ->
      res.send chunk

    # Send through end
    httpres.on 'end', ->
      res.end()
