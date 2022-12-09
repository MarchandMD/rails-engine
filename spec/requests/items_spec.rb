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

      it 'has a sad path' do
        merchant_id = create(:merchant).id

        # missing unit_price; expect rejection
        item_params = {
          "name": "value1",
          "description": "value2",
          "merchant_id": merchant_id
        }
        expect(merchant_id).to be_an Integer

        # valid headers to comply with JSON configurations
        headers = { "CONTENT_TYPE" => 'application/json' }

        # the actual post request using above information, expected rejection
        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

        message = JSON.parse(response.body, symbolize_names: true)

        expect(message).to have_key(:error)
        expect(message[:error]).to eq('incomplete submission')
      end

      it 'ignores attributes sent by the user which are not allowed' do
        # valid merchant_id is required
        merchant_id = create(:merchant).id

        # content to be converted to JSON and sent via post request, with additional param
        item_params = {
          "name": "ignore",
          "description": "the not allowed",
          "unit_price": 100.99,
          "merchant_id": merchant_id,
          "foo_param": "not expected"
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

        message = JSON.parse(response.body, symbolize_names: true)

        expect(message[:data][:attributes]).not_to have_key(:foo_param)
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

      it 'has a sad path' do
        merchant_id = create(:merchant).id
        id = create(:item, merchant_id: merchant_id).id
        item_params = { "name": "patched name" }

        headers = { "CONTENT_TYPE" => 'application/json' }

        patch "/api/v1/items/#{id + 1}", headers: headers, params: JSON.generate(item: item_params)

        expect(response.status).to eq(404)
        expect(response.message).to eq("Not Found")
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

      it 'has a sad path' do
        merchant_id = create(:merchant).id
        id = create(:item, merchant_id: merchant_id).id
        item_params = { "name": "patched name" }

        headers = { "CONTENT_TYPE" => 'application/json' }

        delete "/api/v1/items/#{id + 1}", headers: headers, params: JSON.generate(item: item_params)

        expect(response.status).to eq(404)
      end

      xit 'destroys any invoice if this was the only item on the invoice' do
        # possible all SQL method to bypass lack of relationships and ActiveRecord
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

  describe 'non-RESTful endpoint' do
    it 'can find all based on name search criteria' do
      id = create(:merchant).id
      id2 = create(:merchant).id
      ring_of_gold = create(:item, name: 'Ring of Gold', merchant_id: id)
      silver_ring = create(:item, name: 'Silver Ring', merchant_id: id2)
      lunchbox = create(:item, name: 'lunchbox', merchant_id: id)

      get "/api/v1/items/find_all?name=ring"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items[:data].count).to eq(2)
      expect(items).to have_key(:data)

      expect(items[:data][0]).to have_key(:id)
      expect(items[:data][0][:id]).to eq("#{ring_of_gold.id}")

      expect(items[:data][0]).to have_key(:type)
      expect(items[:data][0][:type]).to eq('item')

      expect(items[:data][0]).to have_key(:attributes)

      expect(items[:data][0][:attributes]).to have_key(:name)
      expect(items[:data][0][:attributes][:name]).to eq(ring_of_gold.name)

      expect(items[:data][0][:attributes]).to have_key(:description)
      expect(items[:data][0][:attributes][:description]).to eq(ring_of_gold.description)

      expect(items[:data][0][:attributes]).to have_key(:unit_price)
      expect(items[:data][0][:attributes][:unit_price]).to eq(ring_of_gold.unit_price)

      expect(items[:data][0][:attributes]).to have_key(:merchant_id)
      expect(items[:data][0][:attributes][:merchant_id]).to eq(ring_of_gold.merchant_id)

      expect(items[:data][1]).to have_key(:id)
      expect(items[:data][1][:id]).to eq("#{silver_ring.id}")

      expect(items[:data][1]).to have_key(:type)
      expect(items[:data][1][:type]).to eq('item')

      expect(items[:data][1]).to have_key(:attributes)

      expect(items[:data][1][:attributes]).to have_key(:name)
      expect(items[:data][1][:attributes][:name]).to eq(silver_ring.name)

      expect(items[:data][1][:attributes]).to have_key(:description)
      expect(items[:data][1][:attributes][:description]).to eq(silver_ring.description)

      expect(items[:data][1][:attributes]).to have_key(:unit_price)
      expect(items[:data][1][:attributes][:unit_price]).to eq(silver_ring.unit_price)

      expect(items[:data][1][:attributes]).to have_key(:merchant_id)
      expect(items[:data][1][:attributes][:merchant_id]).to eq(silver_ring.merchant_id)
    end

    context 'can allow the user to send one or more price-related query parameters' do
      context 'min-price' do
        describe 'happy path' do
          it 'returns a single item >= min-price param' do
            merchant_id = create(:merchant).id
            item1 = create(:item, unit_price: 50, merchant_id: merchant_id)
            item2 = create(:item, unit_price: 51, merchant_id: merchant_id)
            item3 = create(:item, unit_price: 49, merchant_id: merchant_id)

            get "/api/v1/items/find?min_price=50"
            min_priced_item = JSON.parse(response.body, symbolize_names: true)

            expect(min_priced_item).to have_key(:data)
            expect(min_priced_item[:data]).to have_key(:id)
            expect(min_priced_item[:data][:id]).to eq("#{item1.id}")

            expect(min_priced_item[:data]).to have_key(:type)
            expect(min_priced_item[:data][:type]).to eq("item")

            expect(min_priced_item[:data]).to have_key(:attributes)

            expect(min_priced_item[:data][:attributes]).to have_key(:name)
            expect(min_priced_item[:data][:attributes][:name]).to eq("#{item1.name}")

            expect(min_priced_item[:data][:attributes]).to have_key(:description)
            expect(min_priced_item[:data][:attributes][:description]).to eq("#{item1.description}")

            expect(min_priced_item[:data][:attributes]).to have_key(:unit_price)
            expect(min_priced_item[:data][:attributes][:unit_price]).to eq(item1.unit_price)

            expect(min_priced_item[:data][:attributes]).to have_key(:merchant_id)
            expect(min_priced_item[:data][:attributes][:merchant_id]).to eq(merchant_id)
          end
        end

        describe 'sad path' do
          it 'returns 400 when min_price < 0' do
            merchant_id = create(:merchant).id
            item1 = create(:item, merchant_id: merchant_id)

            get "/api/v1/items/find?min_price=0"

            no_items = JSON.parse(response.body, symbolize_names: true)

          end
        end


      end


    end

  end
end
