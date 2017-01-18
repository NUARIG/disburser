class Disburser.DisburserRequests
  constructor: () ->
  render: () ->
    $('#repository_id').on 'change', (e) ->
      if $(this).val() == ''
        $('#new_repository_request_link_label').removeClass('hide')
        $('#new_repository_request_link').addClass('hide')
      else
        new_repository_request_url = $('#repository_id :selected').attr('new_repository_request_url')
        $('#new_repository_request_link').attr('href', new_repository_request_url)
        $('#new_repository_request_link_label').addClass('hide')
        $('#new_repository_request_link').removeClass('hide')


$(document).on 'turbolinks:load', ->
  return unless ($('.disburser_requests.index').length > 0)
  ui = new Disburser.DisburserRequests
  ui.render()