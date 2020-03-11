collection = local_assigns[:collection] || @collection

json.content render(
  partial: 'versions/version',
  collection: collection,
  formats: :html
)

if collection.next_page?
  json.postloader render(
    'blocks/postloader',
    filter: 'b-log_entry',
    next_url: current_url(page: collection.next_page),
    prev_url: (current_url(page: collection.prev_page) if collection.prev_page?)
  )
end
