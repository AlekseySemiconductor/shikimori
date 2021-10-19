json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'reviews/review',
    collection: @collection,
    cached: ->(entry) { CacheHelper.keys entry },
    formats: :html
  )
)

if @collection.size == controller.class::TOPICS_LIMIT
  json.postloader render(
    'blocks/postloader',
    filter: 'b-review',
    next_url: current_url(page: @page + 1),
    prev_url: @page > 1 ? current_url(page: @page - 1) : nil
  )
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
