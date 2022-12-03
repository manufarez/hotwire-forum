Rails.application.routes.draw do
  resources :categories
  get 'discussions/index'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :discussions do
    resources :posts, only: [:create, :show, :edit, :update, :destroy], module: :discussions
    collection do
      get 'category/:id', to: 'categories/discussions#index', as: 'category'
    end
    #If  you want to route /notifications (without the prefix /discussions) to Discussions::NotificationsController, you can specify it with module
    resources :notifications, only: [:create], module: :discussions
  end
  resources :notifications, only: [:index] do
    collection do
      post '/mark_as_read', to: 'notifications#read_all', as: :read
    end
  end
  # Defines the root path route ("/")
  root "main#index"
end
