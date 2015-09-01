require "simple-spreadsheet"

users = SimpleSpreadsheet::Workbook.read("lib/tasks/files/users.xlsx")

users.selected_sheet = users.sheets.first

row_number = 0
first_row = nil
users.first_row.upto(users.last_row) do |line|
	if row_number > 0
		user1 = {
		  name: users.cell(line, 2),
		  email: users.cell(line, 3),
		  password: users.cell(line, 4),
		  phone: users.cell(line, 6),
		  address: users.cell(line, 5),
		  description: users.cell(line, 8),
		  keywords: users.cell(line, 7).split('#').map{|w| w.strip }.select{|w| w.size > 2 },
		  hours: {}
		}

		for num in (10..16)
			if users.cell(line, num) != 'n/a'
				user1[:hours][users.cell(first_row, num)] = {
					from: users.cell(line, num).split('-')[0].strip,
					to: users.cell(line, num).split('-')[1].strip
				}
			end
		end

		u = User.new(user1)
		u.save
		
	else
		first_row = line
	end
	row_number = row_number + 1
end