json.array! users do |user|
	render_partial json, 'users/user_small', { :user => user }
end