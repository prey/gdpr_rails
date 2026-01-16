json.collection @collection do |j|
  json.id j.id
  json.name          j.name
  json.info          j.info
  json.info2         j.info2
  json.created_at    j.created_at
end

json.meta do
  json.current_page(@collection.current_page)
  json.next_page(@collection.next_page)
  json.prev_page(@collection.prev_page)
  json.total_pages(@collection.total_pages)
  json.total_count(@collection.total_count)
end
