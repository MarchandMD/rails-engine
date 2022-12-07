require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe 'Items API endpoints' do
    it 'sends a list of items' do
      merchant_1_id = create(:merchant).id
      merchant_2_id = create(:merchant).id
      create_list(:item, 3, merchant_id: merchant_1_id)
      create_list(:item, 3, merchant_id: merchant_2_id)

      get "/api/v1/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      items[:data].each do |item|
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a String

        expect(item).to have_key(:attributes)

        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to be_a String

        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to be_a String

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a Float

        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a Float
      end
    end

    it 'can send a single item by id' do
      merchant = create(:merchant)
      item = create(:item, merchant_id: merchant.id)

      get "/api/v1/items/#{item.id}"

      expect(response).to be_successful

      single_item = JSON.parse(response.body, symbolize_names: true)

      expect(single_item).to have_key(:data)
      expect(single_item[:data]).to be_a Hash

      expect(single_item[:data]).to have_key(:id)
      expect(single_item[:data][:id]).to be_a String

      expect(single_item[:data]).to have_key(:type)
      expect(single_item[:data][:type]).to eq("item")

      expect(single_item[:data]).to have_key(:attributes)

      expect(single_item[:data][:attributes]).to have_key(:name)
      expect(single_item[:data][:attributes][:name]).to be_a String

      expect(single_item[:data][:attributes]).to have_key(:description)
      expect(single_item[:data][:attributes][:description]).to be_a String

      expect(single_item[:data][:attributes]).to have_key(:unit_price)
      expect(single_item[:data][:attributes][:unit_price]).to be_a Float

      expect(single_item[:data][:attributes]).to have_key(:merchant_id)
      expect(single_item[:data][:attributes][:merchant_id]).to be_an Integer
    end

    context "when attempting to create an item" do
      it 'has a happy path' do
        # happy path, a valid merchant_id is required
        merchant_id = create(:merchant).id

        # content to be converted to JSON and sent via post request
        item_params = {
          "name": "value1",
          "description": "value2",
          "unit_price": 100.99,
          "merchant_id": merchant_id
        }
        expect(merchant_id).to be_an Integer

        # valid headers to comply with JSON configurations
        headers = { "CONTENT_TYPE" => 'application/json' }

        # the actual post request using above information
        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

        # confirm last item equal to data sent
        created_item = Item.last

        expect(response).to be_successful
        expect(created_item.name).to eq(item_params[:name])
        expect(created_item.description).to eq(item_params[:description])
        expect(created_item.unit_price).to eq(item_params[:unit_price])
        expect(created_item.merchant_id).to eq(item_params[:merchant_id])
      end

      xit 'has a sad path' do
        # happy path, a valid merchant_id is required
        merchant_id = create(:merchant).id

        # content to be converted to JSON and sent via post request
        item_params = {
          "name": "value1",
          "description": "value2",
          "merchant_id": merchant_id
        }
        expect(merchant_id).to be_an Integer

        # valid headers to comply with JSON configurations
        headers = { "CONTENT_TYPE" => 'application/json' }

        # the actual post request using above information
        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

        expect { response }.to raise_error
      end

      xit 'ignores attributes sent by the user which are not allowed' do
      end
    end

    context "when updating an item" do
      it 'has a happy path' do
        merchant_id = create(:merchant).id
        id = create(:item, merchant_id: merchant_id).id

        previous_item_name = Item.last.name
        item_params = { "name": "patched name" }
        headers = { "CONTENT_TYPE" => 'application/json' }

        patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({ item: item_params })

        item = Item.find_by(id: id)

        expect(response).to be_successful
        expect(item.name).not_to eq(previous_item_name)
        expect(item.name).to eq("patched name")
      end

      xit 'has a sad path' do
      end
    end

    context "when destroying an item" do
      it 'has a happy path' do
        merchant_id = create(:merchant).id
        item = create(:item, merchant_id: merchant_id)

        expect(Item.count).to eq(1)

        delete "/api/v1/items/#{item.id}"

        expect(response).to be_successful
        expect(Item.count).to eq(0)
        expect { Item.find(item.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      xit 'has a sad path' do
      end

      xit 'destroys any invoice if this was the only item on the invoice' do
      end
    end
  end

  describe "Relationship endpoints" do
    it 'returns a list of items for a merchant' do
      id = create(:merchant).id
      create_list(:item, 3, merchant_id: id)

      get "/api/v1/merchants/#{id}/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      items[:data].each do |item|
        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to eq(id)
      end
    end
  end
end
