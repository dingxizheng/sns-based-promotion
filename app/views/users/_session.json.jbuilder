if not session.access_token.nil?
	json.access_token session.access_token
end

json.expire_at session.expire_at

json.user do
	json.id session.user.user.get_id
	json.url user_url(session.user)

	json.extract! session.user, :name, :description, :created_at, :updated_at
end