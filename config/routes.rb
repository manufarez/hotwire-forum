Rails.application.routes.draw do
  resources :categories
  get 'discussions/index'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :discussions do
    resources :posts, only: [:create, :show, :edit, :update, :destroy], module: :discussions
  end
  # Defines the root path route ("/")
  root "main#index"
end
