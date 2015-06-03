ConversionOptions = require('../app_lib/conversion_options')
ResponseValidator = require('../app_lib/response_validator')
PhantomRunner = require('../app_lib/phantom_runner')
Request = require('request')

module.exports = class ConversionController

  constructor: (@request, @response) ->

  urlToPdf: ->
    conversionOptions = new ConversionOptions(@request.query)
    if conversionOptions.looksGood()
      preflight = Request.head(conversionOptions.source_url)
      preflight.on 'response', (httpResponse) =>
        sourceValidator = new ResponseValidator(httpResponse)
        if sourceValidator.looksGood()
          runner = new PhantomRunner(conversionOptions)
          runner.on 'done', (pdfBinary) =>
            @response.header 'content-type', 'application/pdf'
            if conversionOptions.download is 'true'
              @response.setHeader 'Content-disposition', "attachment; filename=#{conversionOptions.filename}.pdf"
            @response.send pdfBinary
    else
      @response.send conversionOptions.errorMessages().join("<br>")
