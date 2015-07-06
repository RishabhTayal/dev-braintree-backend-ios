Rails.application.routes.draw do
  post "/client_token" => "api#client_token"
  post '/nonce/transaction' => 'api#transaction'

  post '/create_customer' => 'api#create_customer'
  post '/create_merchant' => 'api#create_merchant'
  post '/find_merchant' => 'api#find_merchant'

  root 'api#listAPIs'
end
