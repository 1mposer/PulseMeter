Rails.application.routes.draw do
  scope defaults: { format: :json } do
    resource :scan, only: [] do
      post ":tag_token/open", to: "scans#open", as: :open
    end
    
    resources :sessions, only: [:create, :update, :show] do
      member do
        patch :assign_member
        post :void
        post :drink_purchases, to: "sessions#create_drink_purchase"
        post :food_purchases, to: "sessions#create_food_purchase"
      end
    end
  end
end
