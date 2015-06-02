'use strict'
path = require('path')
express = require('express')
middleware = require('./middleware')
compression = require('compression')
morgan = require('morgan')
env = process.env.APP_ENV or 'production'
config = require('../config/' + env + '.app.config.js')
app = express()
process.chdir path.join(__dirname, '..')
app.use middleware.domain()
app.use morgan('combined')
app.use compression()
require('./webservices/pdf.coffee') app
require('./websiteRoutes.coffee') app
app.use express['static'](__dirname + '/../public', clientMaxAge: -1000 * 60 * 60 * 24)
app.use express['static'](__dirname + '/../favicon', clientMaxAge: -1000 * 60 * 60 * 24)
app.use (err, req, res, next) ->
  console.error err.stack
  res.status(500).send 'Something broke!'
  return
app.listen config.http.port
console.log 'Listening on http://localhost:' + config.http.port + '/'
module.exports = app: app
