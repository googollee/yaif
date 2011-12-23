Yaif::Application.routes.draw do
  resources :users, :only => [:new, :create, :edit, :update]
  resources :sessions, :only => [:new, :create, :destroy]

  resources :tasks

  resources :services do
    resources :triggers
    resources :actions

    member do
      get 'auth'
      get 'redirect_to_auth_url'
      get 'auth_callback'
    end
  end

  match '/services_with_trigger', :to => 'services#services_with_trigger'
  match '/services_with_action', :to => 'services#services_with_action'

  match '/crontab', :to => 'triggers#show_crontab', :format => :text
  match '/trigger', :to => 'triggers#trigger', :format => :text

  scope :constraints => { :protocol => 'http' } do
    match '/signup', :to => redirect { |params, request|
                                        put params
                                        "https://" + request.host_with_port + request.fullpath
    }
    match '/signin', :to => redirect { |params, request|
                                        put params
                                        "https://" + request.host_with_port + request.fullpath
    }
    match '/signout', :to => redirect { |params, request|
                                        put params
                                        "https://" + request.host_with_port + request.fullpath
    }
  end

  root :to => 'sessions#root'
end
