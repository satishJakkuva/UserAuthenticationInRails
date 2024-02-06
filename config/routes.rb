Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :user_details do
    collection do 
      post 'login'
    end
    member do
      put 'update_status'
    end
  end 
  resources :leave_requests do
    member do
      post 'approve'
      post 'reject'
      get 'calculate_leave_duration'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
