json.array! tags do |tag|
	render_partial json, 'tags/tag', { :tag => tag }
end