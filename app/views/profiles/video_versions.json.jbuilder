json.content render(
  partial: 'versions/version',
  collection: @collection,
  formats: :html
)

if @add_postloader
  json.postloader render(
    'blocks/postloader',
    next_url: video_versions_profile_url(page: @page+1)
  )
end
