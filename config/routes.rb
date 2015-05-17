GampApi::Application.routes.draw do

  resources :reviews, except: [:new, :edit] 

  resources :promotions, except: [:new, :edit]

  resources :catagorys, except: [:new, :edit, :show]
  
  resources :users, except: [:new, :edit] do 
    resources :promotions, except: [:new, :edit]
    resources :reviews, except: [:new, :edit] 
    post 'keywords' => 'users#add_keyword'
    delete 'keywords/:keyword' => 'users#delete_keyword'
    post 'logo' => 'users#set_logo'
  end

  # authentication
  post 'signin' => 'accounts#signin'
  post 'signout' => 'accounts#signout'
  post 'signup' => 'accounts#signup_with_email'
  get   'me' => 'accounts#me'

  get 'search/:query' => 'search#query'

  get 'autocomplete/:query' => 'search#autocomplete'

  # errors
  match "*path", :to => "application#handle_404", :via => :all
  
end
