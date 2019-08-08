json.content render(
  partial: 'dialogs/dialog',
  collection: @collection,
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    filter: 'b-dialog',
    next_url: index_profile_dialogs_url(@resource, page: @page + 1)
  )
end
