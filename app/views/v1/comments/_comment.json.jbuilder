json.id comment.get_id

# json.url resource_path_to('comment_url', comment) 

json.extract! comment, :created_at, :updated_at, :body

if comment.parent_id
	parent = Comment.find(comment.parent_id)
	json.parent do 
		json.extract! parent, :created_at, :updated_at, :body, :parent_id
	end
end

if comment.commenteer.present?
	json.commenteer do
		render_partial_small(json, :user, comment.commenteer)
	end
end

json.likes do
	json.count comment.likes
end

json.dislikes do
	json.count comment.dislikes
end