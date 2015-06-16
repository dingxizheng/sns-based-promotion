namespace :database do
  
  desc "populate catagories"
  task catagory: :environment do
  	load 'lib/tasks/files/populate_catagory.rb' 
  end

end
