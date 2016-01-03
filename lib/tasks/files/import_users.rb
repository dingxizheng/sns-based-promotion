require "simple-spreadsheet"

users = SimpleSpreadsheet::Workbook.read("lib/tasks/files/users-2.xlsx")

users.selected_sheet = users.sheets.first

row_number = 0
first_row = nil
users.first_row.upto(users.last_row) do |line|
	# puts users.cell(line, 7).split('#').map{|w| w.strip }.select{|w| w.size > 2 }
	if row_number > 0
		user1 = {
		  # paid: users.cell(line, 1) == "Yes",
		  name: users.cell(line, 1),
		  email: users.cell(line, 2),
		  password: users.cell(line, 3),
		  phone: users.cell(line, 5),
		  address: users.cell(line, 4),
		  description: users.cell(line, 7),
		  keywords: users.cell(line, 6).split('#').map{|w| w.strip }.select{|w| w.size > 2 },
		  hours: {}
		}

		for num in (10..15)
			if users.cell(line, num) != 'n/a'
				begin
					user1[:hours][users.cell(first_row, num)] = {
						from: users.cell(line, num).split('-')[0].strip,
						to: users.cell(line, num).split('-')[1].strip
					}
				rescue
					puts  "Error when reading #{ users.cell(first_row, num) }"
				end
			end
		end

		u = User.find_by({ :email => user1[:email] })

		# if u.present?
		# 	deal1 = {
		# 		customer_id: u.get_id,
		# 		title: users.cell(line, 18),
		# 		description: users.cell(line, 19),
		# 		start_at: users.cell(line, 20),
		# 		expire_at: users.cell(line, 21),
		# 		keywords: users.cell(line, 23).split('#').map{|w| w.strip }.select{|w| w.size > 2 },
		# 	}

		# 	c = Catagory.find_by( { :name => users.cell(line, 22) } )

		# 	if c.present?
		# 		deal1[:catagory_id] = c.get_id
		# 	end

		# 	p = Promotion.new(deal1)
		# 	p.save

		# 	puts "deals created #{ p.title }"
		# end

		if u.present? 
			# subscription = Subscription.new({ :user_id => u.get_id })
			# subscription.product = Product.find("55cfc8df4572696195000002").get_hash
			# subscription.save
			# puts "new subscription #{ u.name }"
			# 
			# u.subscriptions.each{|s| 
			# 	s.approve 
			# 	s.start_to_set_expire_status
   #    			s.start_to_set_activate_status
   #    			puts "subscription #{ u.name }"
			# }
			
			# u.promotions.each{|p| 
			# 	p.approve
			# 	p.save
			# 	puts "promotion approved #{ u.name }    #{ p.title }"
			# }
		else
			u = User.new(user1)
			u.save
			puts "user: #{u.name} added"
		end
 
		# u = User.new(user1)
		# u.save
		
		# puts user1

		# puts "user: #{u.name} added"
		
	else
		first_row = line
	end
	row_number = row_number + 1
end