class Disburser.DisburserRequestEditSpecimenStatus
  constructor: () ->
  render: () ->
    $("input[name='disburser_request[specimen_status]']").on 'change', (e) ->
      if (!($(this).val() == 'partially fulfilled'))
        $('#disburser_request_specimen_type_id').attr('disabled', true)
        $('#disburser_request_specimen_quantity').attr('disabled', true)
        $('#disburser_request_specimen_type_id').val(null)
        $('#disburser_request_specimen_quantity').val('');
      if ($(this).val() == 'partially fulfilled')
        $('#disburser_request_specimen_type_id').removeAttr('disabled')
        $('#disburser_request_specimen_quantity').removeAttr('disabled')
      if (!($(this).val() == 'partially fulfilled') && $(this).val() == $('#specimen_status_original').val())
        $('#disburser_request_specimen_status_comments').val('');
        $('#disburser_request_specimen_status_comments').attr('disabled', true)
        $('#disburser_request_specimen_status_status_at').attr('disabled', true)
      else
        $('#disburser_request_specimen_status_comments').removeAttr('disabled')
        $('#disburser_request_specimen_status_status_at').removeAttr('disabled')

$(document).on 'turbolinks:load', ->
  return unless ($('.disburser_requests.edit_specimen_status').length > 0)
  ui = new Disburser.DisburserRequestEditSpecimenStatus
  ui.render()