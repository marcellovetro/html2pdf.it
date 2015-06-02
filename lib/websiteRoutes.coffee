'use strict'

module.exports = (http) ->
  http.get '/', (req, res, next) ->
    req.url = '/index.html'
    next()
