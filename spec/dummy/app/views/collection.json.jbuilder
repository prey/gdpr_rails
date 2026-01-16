json.collection @collection do |j|
  json.id j.id
end

json.meta do
  json.current_page(@collection.current_page)
  json.next_page(@collection.next_page)
  json.prev_page(@collection.previous_page)
  json.total_pages(@collection.total_pages)
  json.total_count(@collection.total_entries)
end
