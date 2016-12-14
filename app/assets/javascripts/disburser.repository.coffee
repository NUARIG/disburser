class Disburser.Repository
  constructor: () ->
  render: (link) ->
    $(link).on 'click', (e) ->
      $modal = $('#repository_modal')
      $repository = $('#repository_modal .repository')
      $.ajax(this.href).done (response) ->
        $repository.html(response)
        $modal.foundation 'open'

        $('#repository_modal').on('ajax:success', (e, data, status, xhr) ->
          $modal.foundation 'close'
          Turbolinks.visit(location.toString())
        ).on 'ajax:error', (e, xhr, status, error) ->
          $('#edit_repository').html(xhr.responseText)

        $('.repository_form .cancel-link').on 'click', (e) ->
          $modal.foundation 'close'
          e.preventDefault()

        return
      e.preventDefault()
      return
    return

$(document).on 'turbolinks:load', ->
  return unless ($('.repositories.show').length > 0)
  ui = new Disburser.Repository
  ui.render('.edit_repository_link')