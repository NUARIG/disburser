class Disburser.DisburserRequest
  constructor: () ->
  render: () ->
    status = $("input[name='disburser_request[status]'][type='hidden']").val()
    if status == undefined
      $('.disburser_request_form_submitter').on 'submit', (e) ->
        dsiburserRequestmode = $("input[name='disburser_request[status]']:checked").val()
        if dsiburserRequestmode == 'draft'
          dataConfirm = "Please confirm that you would like save your request in 'Draft' status."
        else
          dataConfirm = "Please confirm that you would like save your request in 'Submitted' status."
        if confirm(dataConfirm) == true
          true
        else
          e.preventDefault()
          false

    $('#disburser_request_feasibility').on 'change', (e) ->
      if $(this).is(':checked')
        $('.irb_number .validation').removeClass('required')
      else
        $('.irb_number .validation').addClass('required')

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
  return unless ($('.disburser_requests.new').length > 0 || $('.disburser_requests.create').length > 0 || ('.disburser_requests.edit').length > 0 || ('.disburser_requests.update').length > 0)
  ui = new Disburser.DisburserRequest
  ui.render()