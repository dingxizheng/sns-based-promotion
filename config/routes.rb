GampApi::Application.routes.draw do

  resources :products

  resources :reviews, except: [:new, :edit] 

  resources :promotions, except: [:new, :edit] do 
    post 'report' => 'promotions#report'
    post 'approve' => 'promotions#approve'
    post 'reject' => 'promotions#reject'
    post 'rate' => 'promotions#rate'
    post 'notify' => 'promotions#notify'
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
    end
    post 'newpassword' => 'users#update_password'
    get 'resetpasswordbytoken' => 'users#reset_password_by_admin_token'
    get 'resetrolebytoken' => 'users#reset_role_by_admin_token'
    post 'keywords' => 'users#add_keyword'
    delete 'keywords/:keyword' => 'users#delete_keyword'
    post 'logo' => 'users#set_logo'
    post 'reset' => 'users#reset_password'
    post 'rate' => 'users#rate'
  end

  # authentication
  post 'signin' => 'accounts#signin'
  post 'signout' => 'accounts#signout'
  post 'signup' => 'accounts#signup_with_email'
  get   'me' => 'accounts#me'

  get 'search' => 'search#query'

  get 'autocomplete/:query' => 'search#autocomplete'

  # errors
  match "*path", :to => "application#handle_404", :via => :all
  
end
