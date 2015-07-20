Rails.application.routes.draw do
	post "/client_token" => "api#client_token"
	post '/nonce/transaction' => 'api#transaction'

	post '/create_customer' => 'api#create_customer'
	post '/deletePaymentMethod' => 'api#deletePaymentMethod'

	post '/create_merchant' => 'api#create_merchant'
	post '/find_merchant' => 'api#find_merchant'
	post '/update_merchant' => 'api#update_merchant'

	root 'api#listAPIs'
end
