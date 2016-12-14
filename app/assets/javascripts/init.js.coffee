window.Disburser ||= {}

Disburser.init = ->
  $(document).foundation()

$(document).on 'turbolinks:load', ->
  Disburser.init()