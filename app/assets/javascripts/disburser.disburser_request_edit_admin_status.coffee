class Disburser.DisburserRequestEditAdminStatus
  constructor: () ->
  render: () ->
    $("input[name='disburser_request[data_status]']").on 'change', (e) ->
      if $(this).val() == $('#data_status_original').val()
        $('#disburser_request_data_status_comments').val('');
        $('#disburser_request_data_status_comments').attr('disabled', true)
        $('#disburser_request_data_status_status_at').attr('disabled', true)
      else
        $('#disburser_request_data_status_comments').attr('disabled', false)
        $('#disburser_request_data_status_status_at').attr('disabled', false)

    $("input[name='disburser_request[specimen_status]']").on 'change', (e) ->
      if $(this).val() == $('#specimen_status_original').val()
        $('#disburser_request_specimen_status_comments').val('');
        $('#disburser_request_specimen_status_comments').attr('disabled', true)
        $('#disburser_request_specimen_status_status_at').attr('disabled', true)
      else
        $('#disburser_request_specimen_status_comments').attr('disabled', false)
        $('#disburser_request_specimen_status_status_at').attr('disabled', false)

    $("input[name='disburser_request[status]']").on 'change', (e) ->
      if $(this).val() == $('#status_original').val()
        $('#disburser_request_status_comments').val('');
        $('#disburser_request_status_comments').attr('disabled', true)
        $('#disburser_request_status_at').attr('disabled', true)
      else
        $('#disburser_request_status_comments').attr('disabled', false)
        $('#disburser_request_status_at').attr('disabled', false)

$(document).on 'turbolinks:load', ->
  return unless ($('.disburser_requests.edit_admin_status').length > 0)
  ui = new Disburser.DisburserRequestEditAdminStatus
  ui.render()