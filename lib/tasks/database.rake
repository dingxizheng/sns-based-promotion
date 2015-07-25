namespace :database do
  
  desc "populate catagories"
  task catagory: :environment do
  	load 'lib/tasks/files/populate_catagory.rb' 
  end

  desc "add admin user"
  task add_admin_user: :environment  do
  	mongoid_yml = File.join(Rails.root, "config/mongoid.yml")
    Mongoid.load! mongoid_yml, :test
  	puts User.all.count
  	# load 'lib/tasks/files/add_admin_user.rb'
  end

end
