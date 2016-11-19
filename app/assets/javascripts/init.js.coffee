window.Disburser ||= {}

Disburser.init = ->
  $(document).foundation()

$(document).on 'page:load ready', ->
  Disburser.init()