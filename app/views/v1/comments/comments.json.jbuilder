json.array!(comments) do |comment|

	render_partial json, 'comments/comment', { :comment => comment }

end
