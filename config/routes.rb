VideoAdsApi::Application.routes.draw do

  # first api version
  namespace 'v1' do

    # common reviewable routes
    concern :reviewable do
      resources :reviews, except: [:new, :edit] 
    end

    concern :reportable do
      
    end

    concern :commentable do
      resources :comments, except: [:new, :edit], concerns: [:voteable]
    end

    concern :voteable do
      post 'like', :action => :vote_up
      post 'dislike', :action => :vote_down
    end

    resources :comments, except: [:new, :edit], concerns: [:voteable]

    concern :tag_and_untag do
      post 'tag', :action => :tag
      post 'untag', :action => :untag
    end

    concern :followable do
      post 'follow', :action => :follow
      post 'unfollow', :action => :unfollow
      get 'followers', :action => :followers
      get 'followees', :action => :followees
    end

    resources :promotions, except: [:new, :edit], concerns: [:voteable, :commentable, :tag_and_untag, :followable] do  
      get 'reposts',   :action => "reposts"
      get 'ancestors', :action => "ancestors"
    end

    resources :subscribables, except: [:new, :edit], concerns: [:voteable, :tag_and_untag, :followable]

    resources :users, except: [:new, :edit], concerns: [:voteable, :commentable, :tag_and_untag, :followable] do
      resources :promotions, except: [:new, :edit], concerns: [:voteable, :commentable, :tag_and_untag, :followable] do
          
      end
    end

    resources :tags, except: [:new, :edit] do
    end

    namespace :accounts do 
  		post 'facebooklogin', :action => "signin_with_facebook"
      post 'signup',        :action => "signup_with_email"
      post 'signin',        :action => "signin"
      get  'me',            :action => "me"
    end

    match 'feeds' => 'feeds#timeline', :via => :get
  end

  match 'uploads/images' => 'gridfs#upload_image', :via => :post
  match 'uploads/image/file/:image_id/:filename' => 'gridfs#image', :via => :get
  match 'uploads/video/file/:video_id/:filename' => 'gridfs#video', :via => :get

  match 'v:api/*path', :to => redirect("/api/v1/%{path}"), :via => :all

  # resources :promotions, except: [:new, :edit] do 
  #   post 'report' => 'promotions#report'
  #   post 'approve' => 'promotions#approve'
  #   post 'reject' => 'promotions#reject'
  #   post 'rate' => 'promotions#rate'
  #   post 'notify' => 'promotions#notify'
  #   post 'keywords' => 'promotions#add_keyword'
  #   delete 'keywords/:keyword' => 'promotions#delete_keyword'
  #   get  'approvebyadmintoken' => 'promotions#approve_by_admin_token'
  #   get  'cancelbyadmintoken' => 'promotions#cancel_by_admin_token'
  #   get  'notifybyadmintoken' => 'promotions#notify_by_admin_token' 
  # end

  # resources :devices, except: [:new, :edit, :show, :index, :update]

  # resources :subscriptions, except: [:new, :edit, :update] do 
  #   post 'cancel' => 'subscriptions#cancel'
  #   get  'approvebyadmintoken' => 'subscriptions#approve_by_admin_token'
  #   get  'cancelbyadmintoken' => 'subscriptions#cancel_by_admin_token'
  # end
  
  # resources :users, except: [:new, :edit] do 

  #   resources :promotions, except: [:new, :edit] do 
  #     post 'report' => 'promotions#report'
  #     post 'approve' => 'promotions#approve'
  #     post 'reject' => 'promotions#reject'
  #     post 'rate' => 'promotions#rate'
  #     post 'notify' => 'promotions#notify'
  #     post 'keywords' => 'promotions#add_keyword'
  #     delete 'keywords/:keyword' => 'promotions#delete_keyword'
  #   end

  #   post 'newpassword' => 'users#update_password'
  #   get 'resetpasswordbytoken' => 'users#reset_password_by_admin_token'
  #   get 'resetrolebytoken' => 'users#reset_role_by_admin_token'
  #   post 'keywords' => 'users#add_keyword'
  #   delete 'keywords/:keyword' => 'users#delete_keyword'
  #   post 'reset' => 'users#reset_password'
  #   post 'rate' => 'users#rate'
  # end

  # # authentication
  # post 'signin' => 'accounts#signin'
  # post 'signout' => 'accounts#signout'
  # post 'signup' => 'accounts#signup_with_email'
  # get   'me' => 'accounts#me'

  # get 'search' => 'search#query'

  # get 'suggest' => 'search#suggest'

  # # errors
  # match "*path", :to => "application#handle_404", :via => :all
  
end
