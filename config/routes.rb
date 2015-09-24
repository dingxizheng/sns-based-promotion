GampApi::Application.routes.draw do

  get 'app' => 'mobile#app'

  get 'appversion' => 'mobile#app_version'

  resources :products

  resources :reviews, except: [:new, :edit] 

  resources :images, except: [:new, :edit, :update, :destroy]

  resources :promotions, except: [:new, :edit] do 
    post 'report' => 'promotions#report'
    post 'approve' => 'promotions#approve'
    post 'reject' => 'promotions#reject'
    post 'rate' => 'promotions#rate'
    post 'notify' => 'promotions#notify'
    post 'keywords' => 'promotions#add_keyword'
    delete 'keywords/:keyword' => 'promotions#delete_keyword'
    get  'approvebyadmintoken' => 'promotions#approve_by_admin_token'
    get  'cancelbyadmintoken' => 'promotions#cancel_by_admin_token'
    get  'notifybyadmintoken' => 'promotions#notify_by_admin_token' 
  end

  resources :catagorys, except: [:new, :edit, :show]

  resources :devices, except: [:new, :edit, :show, :index, :update]

  resources :subscriptions, except: [:new, :edit, :update] do 
    post 'cancel' => 'subscriptions#cancel'
    get  'approvebyadmintoken' => 'subscriptions#approve_by_admin_token'
    get  'cancelbyadmintoken' => 'subscriptions#cancel_by_admin_token'
  end
  
  resources :users, except: [:new, :edit] do 

    resources :promotions, except: [:new, :edit] do 
      post 'report' => 'promotions#report'
      post 'approve' => 'promotions#approve'
      post 'reject' => 'promotions#reject'
      post 'rate' => 'promotions#rate'
      post 'notify' => 'promotions#notify'
      post 'keywords' => 'promotions#add_keyword'
      delete 'keywords/:keyword' => 'promotions#delete_keyword'
    end

    post 'newpassword' => 'users#update_password'
    get 'resetpasswordbytoken' => 'users#reset_password_by_admin_token'
    get 'resetrolebytoken' => 'users#reset_role_by_admin_token'
    post 'keywords' => 'users#add_keyword'
    delete 'keywords/:keyword' => 'users#delete_keyword'
    post 'reset' => 'users#reset_password'
    post 'rate' => 'users#rate'
  end

  # authentication
  post 'signin' => 'accounts#signin'
  post 'signout' => 'accounts#signout'
  post 'signup' => 'accounts#signup_with_email'
  get   'me' => 'accounts#me'

  get 'search' => 'search#query'

  get 'suggest' => 'search#suggest'

  # errors
  match "*path", :to => "application#handle_404", :via => :all
  
end
