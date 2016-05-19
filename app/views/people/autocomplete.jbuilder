json.array! @collection do |entry|
  name = (entry.russian if params[:search].contains_russian?) || entry.name

  json.data entry.id
  json.value entry.name
  json.label render 'characters/suggest',
    entry: entry,
    entry_name: name,
    url_builder: "#{params[:kind]}_url"
end
