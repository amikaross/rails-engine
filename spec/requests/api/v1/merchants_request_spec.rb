require 'rails_helper'

describe "Merchants API" do 
  it "gets all merchants" do 
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants).to have_key(:data)
    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant).to have_key(:type)
      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)
      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it "can get one merchant by their id" do 
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful 

    expect(merchant).to have_key(:data)
    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to be_a(String)
  end

  it "can get all items for a given merchant id" do 
    merchant = create(:merchant)
    item_1 = create(:item, merchant: merchant)
    item_2 = create(:item, merchant: merchant)
    item_3 = create(:item, merchant: merchant)

    get "/api/v1/merchants/#{merchant.id}/items"

    items_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(items_data).to have_key(:data)
    expect(items_data[:data]).to be_an(Array)
    expect(items_data[:data].count).to eq(3)

    items_data[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item).to have_key(:attributes)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq(merchant.id)
    end
  end

  it "can handle sad paths and empty (none found) responses"
  
end