json.id review.get_id

json.url review_url( review ) 

json.extract! review, :created_at, :updated_at, :body

json.reviewer do
	json.id review.reviewer.id
	json.name review.reviewer.name
	json.email review.reviewer.email
	json.url user_url( review.reviewer )
end

json.reviewee do
	json.id review.customer.id
	json.name review.customer.name
	json.email review.customer.email
	json.url user_url( review.customer )
end