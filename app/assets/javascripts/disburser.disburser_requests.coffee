class Disburser.DisburserRequests
  constructor: () ->
  render: () ->
    $('.make_a_request #repository_id').on 'change', (e) ->
      if $(this).val() == ''
        $('.make_a_request #new_repository_request_link_label').removeClass('hide')
        $('.make_a_request #new_repository_request_link').addClass('hide')
      else
        new_repository_request_url = $('.make_a_request #repository_id :selected').attr('new_repository_request_url')
        $('.make_a_request #new_repository_request_link').attr('href', new_repository_request_url)
        $('.make_a_request #new_repository_request_link_label').addClass('hide')
        $('.make_a_request #new_repository_request_link').removeClass('hide')


$(document).on 'turbolinks:load', ->
  return unless ($('.disburser_requests.index').length > 0)
  ui = new Disburser.DisburserRequests
  ui.render()