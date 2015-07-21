json.id review.get_id

json.url review_url( review ) 

json.extract! review, :created_at, :updated_at, :body

json.anonymous review.anonymous?

if not review.anonymous? and review.reviewer
	json.reviewer do
		json.id review.reviewer.get_id
		json.name review.reviewer.name
		json.email review.reviewer.email
		json.url user_url( review.reviewer )
		if not review.reviewer.logo.nil?
			json.logo do
				json.image_url review.reviewer.logo.image_url
				json.thumb_url review.reviewer.logo.thumb_url
			end
		end
	end
elsif not review.anonymous? and review.reviewer.nil?
	json.reviewer do
		json.deleted true
	end
else
	json.reviewer do
		json.ip review.anonymity.ip
	end
end

if review.customer
	json.reviewee do
		json.id review.customer.get_id
		json.name review.customer.name
		json.email review.customer.email
		json.url user_url( review.customer )
	end
end

if review.promotion
	json.promotion do
		json.url promotion_url( review.promotion )
		json.id review.promotion.get_id
		json.extract! review.promotion, :title, :description, :status
	end
end