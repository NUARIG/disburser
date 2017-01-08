class Disburser.DisburserRequest
  constructor: () ->
  render: () ->
    $('.remove_methods_justifications_link').on 'click', (e) ->
      if $('#disburser_request_methods_justifications').hasClass('hide')
        $('#disburser_request_methods_justifications').removeClass('hide')
        $(this).addClass('hide')
        $('.methods_justifications_url').addClass('hide')
        $('#disburser_request_methods_justifications').val('')
        $('#disburser_request_methods_justifications_cache').val('')
      else
        $('#disburser_request_methods_justifications').addClass('hide')

      e.preventDefault()

$(document).on 'turbolinks:load', ->
  return unless ($('.disburser_requests.new').length > 0 || $('.disburser_requests.edit').length > 0)
  ui = new Disburser.DisburserRequest
  ui.render()