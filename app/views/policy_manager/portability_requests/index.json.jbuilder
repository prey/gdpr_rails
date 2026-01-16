json.portability_requests @portability_requests do |portability_request|
  json.state portability_request.state
  json.attachment portability_request.attachment
  json.expire_at portability_request.expire_at
end
