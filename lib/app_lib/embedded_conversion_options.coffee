module.exports = class EmbeddedConversionOptions

  constructor: (queryParams) ->
    @margin = queryParams.margin or '1cm'
    @orientation = queryParams.orientation or 'portrait'
    @zoom = queryParams.zoom or '1'
    @html = queryParams.html
    @paperFormat = 'A4'
    @filename = queryParams.filename or 'document.pdf'
    @download = queryParams.download or 'true'

  looksGood: ->
    @errorMessages().length is 0

  errorMessages: ->
    errors = []
    unless @hasEmbeddedHtml()
      errors.push "No HTML embedded in post request. Please embed HTML."
    unless @hasValidMargin()
      errors.push "Invalid margin, write as (value)(unit), e.g. 2cm or 24mm."
    unless @hasValidZoom()
      errors.push "Invalid zoom, write as a decimal with dot as decimal seperator. E.g. 0.75 or 4.50"
    unless @hasValidOrientation()
      errors.push "Invalid orientation, only portrait and landscape are supported values."
    unless @hasValidDownloadOption()
      errors.push "Invalid download option: #{@download} - only true and false are supported."
    errors

  hasEmbeddedHtml: ->
    @html? and String(@html).length isnt 0

  hasValidMargin: ->
    /^\d+(in|cm|mm)$/.test @margin

  hasValidZoom: ->
    /^\d(\.\d{1,3})?$/.test @zoom

  hasValidOrientation: ->
    ['portrait', 'landscape'].indexOf(@orientation) isnt -1

  hasValidDownloadOption: ->
    @download in ['true', 'false']
