json.array!(@comps) do |comp|
  json.extract! comp, :user_id, :account_id, :description, :expiration, :days_until_expiration
  json.url comp_url(comp, format: :json)
end