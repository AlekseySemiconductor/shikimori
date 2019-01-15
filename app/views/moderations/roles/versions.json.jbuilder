json.content render(
  partial: 'versions/version',
  collection: @versions,
  formats: :html
)

if @versions&.next_page?
  json.postloader render(
    'blocks/postloader',
    filter: 'b-log_entry',
    next_url: current_url(page: @versions.next_page),
    prev_url: (
      current_url(page: @versions.prev_page) if @versions.prev_page?
    )
  )
end
