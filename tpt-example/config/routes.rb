Rails.application.routes.draw do
  scope '/api/v1' do
      resources :tours, only: [:index, :show]
  end
end