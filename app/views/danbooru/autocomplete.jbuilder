json.array! @collection do |entry|
  json.data entry.id
  json.value entry.name

  json.label render(
    partial: 'danbooru/suggest',
    formats: :html,
    locals: { entry: entry },
    layout: false
  )
end
