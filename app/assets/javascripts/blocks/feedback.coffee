$(document).on 'page:load', ->
  $feedback = $('.b-feedback')

  $('.marker-positioner', $feedback).on 'ajax:success', (e, data) ->
    $form = $(data)
    $form.find('.b-shiki_editor.unprocessed').shiki_editor()
    modal = new ShikiModal $form

    $form.on 'ajax:success', ->
      $.notice t('blocks.feedback.message_sent')
      modal.close()
