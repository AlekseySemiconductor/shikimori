json.content render(
  partial: 'hentai',
  formats: :html
)

if @collection.next_page?
  json.postloader render(
    'blocks/postloader',
    next_url: current_url(page: @collection.next_page),
    prev_url: (
      current_url(page: @collection.prev_page) if @collection.prev_page?
    ),
    pages_limit: 6
  )
end
