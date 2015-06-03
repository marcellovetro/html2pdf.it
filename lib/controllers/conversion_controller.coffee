# External dependencies
Fs = require('fs')
Uuid = require('node-uuid')

# App dependencies
ConversionOptions = require('../app_lib/conversion_options')
EmbeddedConversionOptions = require('../app_lib/embedded_conversion_options')
PhantomRunner = require('../app_lib/phantom_runner')
Request = require('request')
ResponseValidator = require('../app_lib/response_validator')

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

  htmlToPdf: ->
    conversionOptions = new EmbeddedConversionOptions(@request.body)
    if conversionOptions.looksGood()
      tmpFilePath = "/tmp/#{Uuid.v4()}.html"
      Fs.writeFileSync tmpFilePath, conversionOptions.html
      conversionOptions.source_url = "file://#{tmpFilePath}"
      runner = new PhantomRunner(conversionOptions)
      runner.on 'done', (pdfBinary) =>
        @response.header 'content-type', 'application/pdf'
        if conversionOptions.download is 'true'
          @response.setHeader 'Content-disposition', "attachment; filename=#{conversionOptions.filename}"
        @response.send pdfBinary
    else
      @response.send JSON.stringify(conversionOptions.errorMessages())
