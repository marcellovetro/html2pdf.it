ConversionController = require('./controllers/conversion_controller.coffee')

module.exports = (http) ->
  http.get '/', (req, res, next) ->
    req.url = '/index.html'
    next()
  http.get '/url2pdf', (req, res, next) ->
    new ConversionController(req, res).urlToPdf()
  http.post '/html2pdf', (req, res, next) ->
    new ConversionController(req, res).htmlToPdf()
