json.array!(reviews) do |review|

	json.partial! :partial => 'reviews/review', :locals => { :review => review }

end
