'use strict'
spawn = require('child_process').spawn
path = require('path')
fs = require('fs')
uuid = require('node-uuid')
format = require('util').format
request = require('request')
slugifyUrl = require('slugify-url')
FORMATS = [
  'A3'
  'A4'
  'A5'
  'Legal'
  'Letter'
  'Tabloid'
]
ORIENTATIONS = [
  'portrait'
  'landscape'
]
marginRegExp = /^\d+(in|cm|mm)$/
zoomRegExp = /^\d(\.\d{1,3})?$/

module.exports = (app) ->
  app.get '/', (req, res, next) ->
    url = req.query.url
    filename = slugifyUrl(url)
    if req.query.filename
      filename = req.query.filename
    if !url
      return next('route')
      #skip to html view
    if url.indexOf('http://') != 0 and url.indexOf('https://') != 0
      url = 'http://' + url
    paperFormat = req.query.format or 'A4'
    if FORMATS.indexOf(paperFormat) == -1
      return res.status(400).send(format('Invalid format, the following are supported: %s', FORMATS.join(', ')))
    orientation = req.query.orientation or 'portrait'
    if ORIENTATIONS.indexOf(orientation) == -1
      return res.status(400).send(format('Invalid orientation, the following are supported: %s', ORIENTATIONS.join(', ')))
    margin = req.query.margin or '1cm'
    if !marginRegExp.test(margin)
      return res.status(400).send(format('Invalid margin, the following formats are supported: 0cm, 1cm, 2cm, 1in, 13mm'))
    zoom = req.query.zoom or '1'
    if !zoomRegExp.test(zoom)
      return res.status(400).send(format('Invalid zoom, the following kind of formats are supported: 1, 0.5, 9.25, 0.105'))
    request.head url, (err, resp) ->

      generatePdf = ->
        tmpFile = path.join(__dirname, '../../tmp', uuid.v4() + '.pdf')
        outputLog = ''
        req.connection.setTimeout 2 * 60 * 1000
        #two minute timeout
        options = [
          '--web-security=no'
          '--ssl-protocol=any'
          path.join(__dirname, '../rasterize/rasterize.js')
          url
          tmpFile
          paperFormat
          orientation
          margin
          zoom
        ]
        rasterizeArguments = [
          'phantomjs'
          options
        ]
        console.log rasterizeArguments
        pdfProcess = spawn.apply(this, rasterizeArguments)
        pdfProcess.stdout.on 'data', (data) ->
          console.log 'pdf: ' + data
          outputLog += data
          return
        pdfProcess.stderr.on 'data', (data) ->
          console.error 'pdf: ' + data
          outputLog += data
          return
        pdfProcess.on 'close', (code) ->
          if code
            if code == 100
              return res.status(400).send(outputLog)
            return next(new Error('Wrong code: ' + code))
          res.header 'content-type', 'application/pdf'
          if req.query.download == 'true'
            res.setHeader 'Content-disposition', 'attachment; filename=' + filename + '.pdf'
          if req.query.downloadToken
            res.setHeader 'Set-Cookie', 'downloadToken=' + req.query.downloadToken
          stream = fs.createReadStream(tmpFile)
          stream.pipe res
          stream.on 'error', next
          stream.on 'close', ->
            fs.unlink tmpFile
            return
          return
        return

      if err
        return res.status(400).send(format('Cannot get %s: %s', url, err.message))
      if !/2\d\d/.test(resp.statusCode)
        return res.status(400).send(format('Cannot get %s: http status code %s', url, resp.statusCode))
      if !/text|html/.test(resp.headers['content-type'])
        return res.status(400).send(format('Cannot get %s: returns content type %s. You must point html2pdf.it to HTML or TEXT content', url, resp.headers['content-type']))
      generatePdf()
