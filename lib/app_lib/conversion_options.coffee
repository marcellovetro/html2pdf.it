slugifyUrl = require('slugify-url')

module.exports = class ConversionOptions

  constructor: (queryParams) ->
    @margin = queryParams.margin or '1cm'
    @orientation = queryParams.orientation or 'portrait'
    @zoom = queryParams.zoom or '1'
    @source_url = queryParams.source_url or ''
    @paperFormat = 'A4'
    @filename = queryParams.filename or slugifyUrl(@source_url)
    @download = queryParams.download or 'true'

  looksGood: ->
    !@hasErrors()

  hasErrors: ->
    @errorMessages().length isnt 0

  errorMessages: ->
    errors = []
    unless @hasValidMargin()
      errors.push "Invalid margin, write as (value)(unit), e.g. 2cm or 24mm."
    unless @hasValidZoom()
      errors.push "Invalid zoom, write as a decimal with dot as decimal seperator. E.g. 0.75 or 4.50"
    unless @hasValidOrientation()
      errors.push "Invalid orientation, only portrait and landscape are supported values."
    unless @hasValidSourceUrl()
      errors.push "Invalid source_url: #{@source_url}"
    unless @hasValidDownloadOption()
      errors.push "Invalid download option: #{@download} - only true and false are supported."
    errors

  hasValidMargin: ->
    /^\d+(in|cm|mm)$/.test @margin

  hasValidZoom: ->
    /^\d(\.\d{1,3})?$/.test @zoom

  hasValidOrientation: ->
    ['portrait', 'landscape'].indexOf(@orientation) isnt -1

  hasValidSourceUrl: ->
    @source_url.indexOf('http') is 0
  hasValidDownloadOption: ->
    @download in ['true', 'false']
