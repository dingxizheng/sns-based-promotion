if not session.access_token.nil?
	json.access_token session.access_token
end

json.expire_at session.expire_at

json.user do
	render_partial json, 'users/user_small', { :user => session.user }
	# json.id session.user.get_id
	# json.url v1_user_url(session.user)

	# json.extract! session.user, :name, :description, :created_at, :updated_at
end