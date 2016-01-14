json.id user.get_id

json.url resource_path_to('user_url', user)

json.name user.name

json.avatar user.get_avatar
# json.roles user.roles.pluck :name
