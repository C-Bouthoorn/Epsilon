Server.mdb = false

  MongoClient.connect Server.config.database.url, (err, db) ->
    if err
      return Server.error err

    Server.mdb = db


# If we don't have a connection, it doesn't work anyway
unless server.mdb
  server.log "No connection, assume MDB false"
  send false
  return

# I give my database 2 seconds to respond if it works
to = setTimeout (->
  server.error "Database failed to connect!"

  send false
), 2000

server.mdb.collection('test').find({"test": "OK"}).toArray (err, items) ->
  if err
    return server.error err

  if items[0].test == "OK"
    send true
    clearTimeout to
