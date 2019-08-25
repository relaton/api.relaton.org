Rails.application.routes.draw do
  namespace :api do
    resource :standard, only: [:show]
  end
end
