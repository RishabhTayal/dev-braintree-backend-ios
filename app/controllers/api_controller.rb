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
		service_fee_amount = ((params[:amount].to_f * service_fee_percent.to_f).to_f/100.0).round(2);
		p service_fee_amount
		p params[:amount].to_f
		result = Braintree::Transaction.sale(
			:merchant_account_id => params[:merchant_account_id],
			:amount => params[:amount].to_f,
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
			p result.errors
			# render :json => {"errors" => result.errors}, :status => 400
			render nothing: true
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
				:first_name => params[:merchant_first_name], 
				:last_name => params[:merchant_last_name],
				:email => params[:merchant_email],
				:phone => params[:merchant_phone],
				:date_of_birth => params[:merchant_dob],
				:address => {
					:street_address => params[:merchant_address_street],
					:locality => params[:merchant_address_locality],
					:region => params[:merchant_address_region],
					:postal_code => params[:merchant_address_postal]
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
		p merchant_account.individual_details
		p merchant_account.funding_details.account_number_last_4
		render :json => {'result' => ['account_number' => merchant_account.funding_details.account_number_last_4, 'descriptor' => merchant_account.funding_details.descriptor]}
	end

	def update_merchant
		parameters = {
			'funding' => {
				'descriptor' => 'Bank Account',
				'destination' => Braintree::MerchantAccount::FundingDestination::Bank,
				'account_number' => params[:bank_account],
				'routing_number' => params[:routing_number]
				}
			}
		if params[:dob]
			parameters['individual'] = {
				'date_of_birth' => params[:dob]
			}
		end

		result = Braintree::MerchantAccount.update(params[:merchant_account_id], parameters)
		if result.success?
			render :json => {'success' => true}
		else
			p result.errors
			render :json => {'success' => false}
		end
	end
end
