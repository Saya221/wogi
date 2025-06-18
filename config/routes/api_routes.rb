module ApiRoutes
  def self.extended(router)
    router.instance_exec do

      namespace :api, format: :json do
        namespace :v1 do
          post :login, to: "sessions#login"
          delete :logout, to: "sessions#logout"

          # HealthChecks
          get :ping, to: "health_checks#ping"

          # Admin
          namespace :admin do
            resources :users, only: %i[index show create]
            resources :brands, only: %i[index show create update destroy] do
              resources :products, only: %i[index show create update destroy]
            end
            resources :cards, only: %i[index] do
              member do
                patch :approved
                patch :rejected
              end
            end
            resources :reports, only: %i[index]
          end

          # Client
          namespace :client do
            resources :cards, only: %i[index show create update destroy] do
              member do
                patch :rejected
                patch :activate_accessible_product
              end
            end
            resources :products, only: %i[index]
            resources :reports, only: %i[index]
          end

        end
      end

    end
  end
end
