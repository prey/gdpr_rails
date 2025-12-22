Rails.application.routes.draw do
  mount PolicyManager::Engine => '/terms'
end
