json.array!(@users) do |user|
  json.extract! user, :email, :password_digest, :remember_token, :admin
  json.url user_url(user, format: :json)
end