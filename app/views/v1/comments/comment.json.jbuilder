json.id comment.get_id

json.url resource_path_to('comment_url', comment) 

json.extract! comment, :created_at, :updated_at, :body

if comment.parent_id
	parent = Comment.find(comment.parent_id)
	json.parent do 
		json.extract! parent, :created_at, :updated_at, :body, :parent_id
	end
end

json.commenteer do
	json.id comment.commenteer.get_id
	json.name comment.commenteer.name
	json.avatar comment.commenteer.get_avatar
end

if comment.get_commentee
	json.type comment.get_commentee.class.name.downcase
	json.commentee do
		render_partial_small comment.get_commentee.class.name.downcase.to_sym, comment.get_commentee
	end
end

json.likes do
	json.count comment.up_vote_count
end

json.dislikes do
	json.count comment.down_vote_count
end