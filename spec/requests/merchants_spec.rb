require 'rails_helper'

RSpec.describe 'Merchants', type: :request do
  describe 'Merchants API endpoints' do
    it 'returns merchants' do
      create_list(:merchant, 3)
      get '/api/v1/merchants'
      expect(json).not_to be_empty
      expect(json.size).to eq(1)
    end

    it 'sends a list of merchants' do
      create_list(:merchant, 3)
      get '/api/v1/merchants'
      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      merchants[:data].each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a String

        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a String
      end
    end

    it 'returns an array when 1  merchant present' do
      create(:merchant)
      get '/api/v1/merchants'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)

      merchants[:data].each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a String

        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a String
      end

      expect(merchants[:data]).to be_an Array
    end

    it 'returns an array when 0 merchants present' do
      get '/api/v1/merchants'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)
      expect(Merchant.all.count).to eq(0)
      expect(merchants[:data]).to be_an Array
    end

    xit 'does not include data about merchant items or invoices' do
    end

    it 'can get a single merchant' do
      id = create(:merchant).id

      get "/api/v1/merchants/#{id}"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:id]).to be_a String

      expect(merchant[:data]).to have_key(:type)
      expect(merchant[:data][:type]).to eq("merchant")

      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to be_a String
    end
  end

  context 'returns the merchant for an item' do
    it 'has a happy path' do
      merchant = create(:merchant)

      item = create(:item, merchant_id: merchant.id)

      get "/api/v1/items/#{item.id}/merchant"

      expect(response).to be_successful

      merchant_response = JSON.parse(response.body, symbolize_names: true)
      expect(merchant_response).to have_key(:data)
      expect(merchant_response.count).to eq(1)

      expect(merchant_response[:data]).to have_key(:id)
      expect(merchant_response[:data][:id]).to eq("#{merchant.id}")

      expect(merchant_response[:data]).to have_key(:type)
      expect(merchant_response[:data][:type]).to eq('merchant')

      expect(merchant_response[:data]).to have_key(:attributes)

      expect(merchant_response[:data][:attributes]).to have_key(:name)
      expect(merchant_response[:data][:attributes][:name]).to eq(merchant.name)
    end

    xit 'has a sad path' do
    end
  end

  context "non-RESTful route" do
    it 'can find based on search criteria' do
      create(:merchant, name: 'Turing')
      f_mart = create(:merchant, name: 'Ring World')

      get "/api/v1/merchants/find?name=ring"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)
      expect(merchant.count).to eq(1)
      expect(merchant).to have_key(:data)

      expect(merchant[:data]).to have_key(:id)
      expect(merchant[:data][:id]).to eq("#{f_mart.id}")

      expect(merchant[:data]).to have_key(:type)
      expect(merchant[:data][:type]).to eq('merchant')

      expect(merchant[:data]).to have_key(:attributes)

      expect(merchant[:data][:attributes]).to have_key(:name)
      expect(merchant[:data][:attributes][:name]).to eq('Ring World')
    end

  end

end
