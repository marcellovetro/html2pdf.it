module.exports = class ResponseValidator

  constructor: (@httpResponse) -> #Incoming message

  looksGood: ->
    @resourceExists() or @resourceIsHtml()

  resourceExists: ->
    200 <= @httpResponse.statusCode <= 299

  resourceIsHtml: ->
    /html/.test @httpResponse.headers['content-type']
