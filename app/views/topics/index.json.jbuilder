json.content JsExports::Supervisor.instance.sweep(render(
  partial: 'topics/topic',
  collection: @forums_view.topic_views,
  as: :topic_view,
  formats: :html,
  cache: true
))

if @forums_view.next_page_url
  json.postloader render 'blocks/postloader',
    filter: 'b-topic',
    next_url: @forums_view.next_page_url,
    prev_url: @forums_view.prev_page_url
end

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
