
catagories = [{ :name => "Beauty & Wellness", :icon => "public/icons/Beauty&wellness.png"} ,
              { :name => "Food & Drinks", :icon => "public/icons/food&drinks.png"} ,
              { :name => "Home & Reno", :icon => "public/icons/home&reno.png"} ,
              { :name => "Auto", :icon => "public/icons/Auto.png"} ,
              { :name => "Sport & Fitness", :icon => "public/icons/Sport&fitness.png"} ,
              { :name => "Travel", :icon => "public/icons/Travel.png"} ,
              { :name => "Events", :icon => "public/icons/events.png"} ,
              { :name => "Apparel", :icon => "public/icons/Apparel.png"} ,
              { :name => "Electronics", :icon => "public/icons/Electronics.png"} ,
              { :name => "Finance", :icon => "public/icons/Finance.png"} ,
              { :name => "Other", :icon => "public/icons/Other.png"}]


catagories.each do |c|

  # puts c
  filename = c[:icon]

  catagory = Catagory.where(c.except!(:icon)).first

  puts c[:name], ENV['MONGO_USERNAME']

  if not catagory.present?

    puts 'adding...'

  	puts 'import catagory:' + c[:name]

    cgr = Catagory.new(c.except!(:icon))
    cgr.save

    icon = Image.new
    icon.store(nil, File.read(filename))
    icon.save

    cgr.icon = icon

  elsif catagory.present?
    puts 'new icon...'

  	icon = Image.new
    icon.store(nil, File.read(filename))
    icon.save

  	catagory.icon = icon
  end

end
