
products = [
	{ :name => '1 Month Membership', :price => 9.9, :description => '1 Month Membership', :time => 1 * 30 * 24 * 60 * 60 },
	{ :name => '3 Months Membership', :price => 24.9, :description => '3 Months Membership', :time => 3 * 30 * 24 * 60 * 60},	
	{ :name => '6 Months Membership', :price => 39.9, :description => '6 Months Membership', :time => 6 * 30 * 24 * 60 * 60},
	{ :name => '1 Year Membership', :price => 69.9, :description => '1 Year Membership', :time => 12 * 30 * 24 * 60 * 60}
]

Product.delete_all

products.each do |p|
	pro = Product.create(p)
	puts pro.get_hash
end
