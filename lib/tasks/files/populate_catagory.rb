
catagories = [{ :name => "Beauty & Wellness", :icon => "public/icons/wellness-beauty.png"} ,
              { :name => "Food & Drinks", :icon => "public/icons/food-drinks.png"} ,
              { :name => "Grocery", :icon => "public/icons/groceries.png"} ,
              { :name => "Home & Reno", :icon => "public/icons/home-reno.png"} ,
              { :name => "Auto", :icon => "public/icons/auto.png"} ,
              { :name => "Sports & Fitness", :icon => "public/icons/sports-fitness.png"} ,
              { :name => "Travel", :icon => "public/icons/travel.png"} ,
              { :name => "Events", :icon => "public/icons/events.png"} ,
              { :name => "Recreational", :icon => "public/icons/recreation.png"} ,
              { :name => "Others", :icon => "public/icons/other-misc.png"}]


catagories.each do |c|

  # puts c
  filename = c[:icon]

  if not Catagory.where(c.except!(:icon)).first.present?

  	puts 'import catagory:' + c[:name]

    cgr = Catagory.new(c.except!(:icon))

    icon = Image.new
    icon.store(nil, File.read(filename))
    icon.save
    cgr.icon = icon
    cgr.save

  end

end
