class Disburser.RepositoryUser
  constructor: () ->
  render: (link) ->
    $(link).on 'click', (e) ->
      $modal = $('#repository_user_modal')
      $repository_user = $('#repository_user_modal #repository_user')
      $.ajax(this.href).done (response) ->
        $repository_user.html(response)
        $modal.foundation 'open'

        init = () ->
          usersUrl = $('#users_url').attr('href')
          $('#repository_user_username').select2
            ajax:
              url: usersUrl
              dataType: 'json'
              delay: 250
              data: (params) ->
                {
                  q: params.term
                  page: params.page
                }
              processResults: (data, params) ->
                params.page = params.page or 1
                results = $.map(data.users, (obj) ->
                  obj.id = obj.username
                  obj.text = "<b>Name: </b>" + obj.first_name + " " + obj.last_name + " <b>Username: </b>" + obj.username + " <b>Email: </b>" + obj.email
                  obj
                )

                {
                  results: results
                  pagination: more: params.page * 10 < data.total
                }
              cache: true
            escapeMarkup: (markup) ->
              markup
            minimumInputLength: 2

          $('#repository_user_username').on 'select2:select', (e) ->
            $(this).blur()
            return
          return

        init()

        $('#repository_user_modal').on('ajax:success', (e, data, status, xhr) ->
          $modal.foundation 'close'
          Turbolinks.visit(location.toString())
        ).on 'ajax:error', (e, xhr, status, error) ->
          $('#repository_user').html(xhr.responseText)
          init()

        $('.repository_user_form .cancel-link').on 'click', (e) ->
          $modal.foundation 'close'
          e.preventDefault()
          return false

        return
      e.preventDefault()
      return
    return

$(document).on 'turbolinks:load', ->
  return unless $('.repository_users.index').length > 0
  ui = new Disburser.RepositoryUser
  ui.render('.repository_user_link')