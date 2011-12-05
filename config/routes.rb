Yaif::Application.routes.draw do
  resources :users, :only => [:new, :create, :edit, :update]
  resources :sessions, :only => [:new, :create, :destroy]
  resources :tasks

  resources :services do
    resources :triggers
    resources :actions

    member do
      get 'auth'
      get 'auth_callback'
    end
  end

  match '/services_with_trigger', :to => 'services#services_with_trigger'
  match '/services_with_action', :to => 'services#services_with_action'

  match '/signup', :to => 'users#new'
  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

  root :to => 'sessions#root'
end
