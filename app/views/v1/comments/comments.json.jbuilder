json.array!(comments) do |comment|

	render_partial 'comments/comment', :locals => { :comment => comment }

end
