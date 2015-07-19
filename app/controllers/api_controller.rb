class ApiController < ApplicationController

	respond_to :json

	def listAPIs
		test_routes = []
		routes = Rails.application.routes.routes.each do |route|
			route = route.path.spec.to_s
			test_routes << route
			# test_routes << route if route.starts_with?('/api')
		end
		render :json => JSON.pretty_generate(test_routes)
	end

	def client_token
		token = Braintree::ClientToken.generate(
			:customer_id => params[:customer_id]
			)
		render :json => {"token" => token}
	end 

	def transaction
		# begin
		service_fee_percent = ENV["BT_SERVICE_FEE"] || 7;
		p service_fee_percent;
		service_fee_amount = (params[:amount] * service_fee_percent.to_f).to_f/100.0;
		p service_fee_amount
		result = Braintree::Transaction.sale(
			:merchant_account_id => params[:merchant_account_id],
			:amount => params[:amount],
			:payment_method_nonce => params[:nonce],
			:service_fee_amount => service_fee_amount.to_f,
			:options => {
				:submit_for_settlement => true,
				:store_in_vault_on_success => true
			}
			);
		if result.success? == true
			render :json => {'result' => result.transaction.status}
		else
			render :json => {"errors" => result.errors}, :status => 400
		end
		# rescue Exception => e
		# 	render :json => {"errors" => [e.message]}, :status => 500
		# end
	end

	def create_customer
		result = Braintree::Customer.create(
			:first_name => params[:first_name],
			:last_name => params[:last_name],
			:email => params[:email],
			:phone => params[:phone]
			)
		if result.success?
			render :json => {'result' => result.customer.id}
		else
			render :json => {'errors' => result.errors}, :status => 400
		end
	end

	def create_merchant
		result = Braintree::MerchantAccount.create(
			:individual => {
				:first_name => params[:merchant_name], 
				:last_name => params[:merchant_name],
				:email => params[:merchant_email],
				:phone => params[:merchant_phone],
				:date_of_birth => "1980-02-20",
				:address => {
					:street_address => "111 Main St",
					:locality => "Chicago",
					:region => "IL",
					:postal_code => "60622"
				}
				},
				:business => {
					:legal_name => params[:shop_name]
					},
					:funding => {
						:descriptor => "Bank Account",
						:destination => Braintree::MerchantAccount::FundingDestination::Bank,
						:account_number => params[:bank_account],
						:routing_number => params[:routing_number]
						},
						:tos_accepted => true,
						:master_merchant_account_id => "repairshift"
						)
		if result.success?
			render :json => {"merchant_account_id" => result.merchant_account.id}
		else
			# render :json => {"errors" => result.errors}, :status => 400
			p result.errors
			render nothing: true
		end
	end

	def find_merchant
		p params
		account_id = params[:merchant_account_id]
		merchant_account = Braintree::MerchantAccount.find(account_id)
		render :json => merchant_account.funding_details
	end
end
