window.Disburser ||= {}

class Url
  constructor: (@url) ->

  sub: (params) ->
    url = @url
    newUrl = @url
    queryString = []
    encodedArg = undefined
    encodedParam = undefined
    param = undefined
    for param of params
      `param = param`
      if params.hasOwnProperty(param)
        encodedParam = encodeURIComponent(param)
        encodedArg = encodeURIComponent(params[param])
        newUrl = url.replace(':' + param, encodedArg)
        if url == newUrl
          queryString.push encodedParam + '=' + encodedArg
        url = newUrl
    if queryString.length > 0
      if url.indexOf('?') > 0
        url + queryString.join('&')
      else
        url + '?' + queryString.join('&')
    else
      url

  parameters: ->
    $.map @url.match(/:\w+/g) or [], (o, i) ->
      o.substring 1

Disburser.init = ->
  $(document).foundation()

Disburser.Url = Url

$(document).on 'turbolinks:load', ->
  Disburser.init()
  $(".datepicker").datepicker
    altFormat: "mm/dd/yy"
    dateFormat: "mm/dd/yy"
    # dateFormat: "yy-mm-dd"
  $('.datepicker').datepicker()