require 'rails_helper'

RSpec.describe ApiController, type: :controller do
	it 'fetches client token' do
		params = {
			'customer_id' => '19249159'
		}

		post 'client_token', params, {}
		expect(response.status).to eq 200
		expect(JSON.parse(response.body)['token']).to be
	end

	xit 'processes a transaction successfully' do
		params = {
			'amount' => 10.0
		}

		post 'transaction', params, {}
		expect(response.status).to eq 200
	end

end