class Disburser.Repository
  constructor: () ->
  render: () ->
    return

$(document).on 'turbolinks:load', ->
  return unless ($('.repositories.new').length > 0 || $('.repositories.edit').length > 0)
  ui = new Disburser.Repository
  ui.render()