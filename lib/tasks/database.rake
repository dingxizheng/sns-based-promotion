namespace :database do
  
  desc "populate catagories"
  task :populate_catagory => :environment do
  	Mongoid.load!("config/mongoid.yml", :test)
  	load 'lib/tasks/files/populate_catagory.rb' 
  end

  desc "add admin user"
  task :add_admin_user => :environment  do
  	Mongoid.load!("config/mongoid.yml", :test)
  	User.reindex
  	Sunspot.commit
	# puts User.all.count
  	# load 'lib/tasks/files/add_admin_user.rb'
  end

end
