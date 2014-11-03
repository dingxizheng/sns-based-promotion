json.apitoken session.access_token

json.expire_at session.expire_at

#json.user json.extract! session.user

json.user do
	json.partial! partial: 'users/user', :locals => {user: session.user}
end