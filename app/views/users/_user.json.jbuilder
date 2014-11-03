json.id user.get_id

json.url user_url(user)

json.keywords user.keywords

json.extract! user, :name, :email, :address, :phone, :created_at, :updated_at
