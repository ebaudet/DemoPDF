Rails.application.routes.draw do
  root to: 'home#index'
  post '/', to: 'home#generatePdf', as: 'generatePdf'
end
