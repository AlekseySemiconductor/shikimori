json.content JsExports::Supervisor.instance.sweep(
  render(
    partial: 'moderations/abuse_requests/abuse_request',
    collection: [@resource],
    cached: true,
    formats: :html
  )
)

json.JS_EXPORTS JsExports::Supervisor.instance.export(current_user)
