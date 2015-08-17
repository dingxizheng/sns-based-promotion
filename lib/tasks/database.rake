namespace :database do

  desc "populate testers"
  task :populate_testers => :environment do
  	Mongoid.load!("config/mongoid.yml", :test)
  	load 'lib/tasks/files/add_testers.rb'
  	User.reindex
  	Sunspot.commit
  end

  desc "mongodb reindex"
  task :mongo_reindex => :environment do
    Mongoid.load!("config/mongoid.yml", :production)
    Rake::Task['RAILS_ENV=production db:mongoid:create_indexes'].invoke
  end

  desc "sunspot reindex"
  task :solr_reindex => :environment do
    User.reindex
    Promotion.reindex
    Sunspot.commit
  end
  
  desc "populate catagories"
  task :populate_catagory => :environment do
  	Mongoid.load!("config/mongoid.yml", :production)
  	load 'lib/tasks/files/populate_catagory.rb' 
  end

  desc "import products into the database"
  task :import_products => :environment do
  	Mongoid.load!("config/mongoid.yml", :production)
  	load 'lib/tasks/files/import_products.rb' 
  end

  desc "add admin user"
  task :add_admin_user => :environment  do
  	Mongoid.load!("config/mongoid.yml", :test)
    # User.all.each { |user|
    #   user.save
    #   user.promotions.each { |pro|
    #     pro.save
    #   }
    # }
  	# User.reindex
  	# Sunspot.commit
	   # puts User.all.count
  	load 'lib/tasks/files/add_admin_user.rb'
  	# Rake::Task['db:mongoid:create_indexes'].invoke
  end

end
