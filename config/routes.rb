Rails.application.routes.draw do
	post "/client_token" => "api#client_token"

	post '/nonce/transaction' => 'api#transaction'
	post '/release_from_escrow' => 'api#release_from_escrow'
	post '/find_transaction' => 'api#find_transaction'
	
	post '/create_customer' => 'api#create_customer'

	post '/create_merchant' => 'api#create_merchant'
	post '/find_merchant' => 'api#find_merchant'
	post '/update_merchant' => 'api#update_merchant'

	root 'api#listAPIs'
end
