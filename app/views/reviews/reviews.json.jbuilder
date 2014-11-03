json.array!(reviews) do |review|

	json.partial! :partial => 'reviews/review', :local => { :review => review }

end
