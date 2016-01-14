json.array! @users do |user|
	json.partial! partial: 'users/listitem', :locals => { user: user }
end