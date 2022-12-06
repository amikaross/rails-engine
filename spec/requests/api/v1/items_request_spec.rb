require 'rails_helper'

describe "Items API" do 
  it "gets all items" do 
    create_list(:item, 4)

    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items.count).to eq(4)

    items.each do |item|
      expect(item).to have_key(:name)
      expect(item[:name]).to be_a(String)
  
      expect(item).to have_key(:description)
      expect(item[:description]).to be_a(String)
  
      expect(item).to have_key(:unit_price)
      expect(item[:unit_price]).to be_a(Float)
  
      expect(item).to have_key(:merchant_id)
      expect(item[:merchant_id]).to be_an(Integer)
    end
  end

  it "can get one item by its id" do 
    id = create(:item).id

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful 

    expect(item).to have_key(:name)
    expect(item[:name]).to be_a(String)

    expect(item).to have_key(:description)
    expect(item[:description]).to be_a(String)

    expect(item).to have_key(:unit_price)
    expect(item[:unit_price]).to be_a(Float)

    expect(item).to have_key(:merchant_id)
    expect(item[:merchant_id]).to be_an(Integer)
  end

  it "can create a new item" do 
    merchant_id = create(:merchant).id
    item_params = {
      name: "value1",
      description: "value2",
      unit_price: 100.99,
      merchant_id: merchant_id
    }

    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    created_item = Item.last

    expect(response).to be_successful

    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "can edit an existing item" do 
    merchant = create(:merchant)
    id = create(:item, merchant: merchant).id
    previous_name = Item.last.name
    previous_price = Item.last.unit_price
    item_params = {
      name: "Magical Mister Mistofoles",
      unit_price: 1111.11,
    }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})

    item = Item.find(id)

    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("Magical Mister Mistofoles")
    expect(item.unit_price).to_not eq(previous_price)
    expect(item.unit_price).to eq(1111.11)
  end

  it "can get the merchant data for a given Item ID" do 
    merchant = create(:merchant)
    other_merchant = create(:merchant)
    id = create(:item, merchant: merchant).id

    get "/api/v1/items/#{id}/merchant"

    merchant_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant_data).to have_key(:data)
    expect(merchant_data[:data]).to have_key(:attributes)
    expect(merchant_data[:data][:attributes]).to have_key(:name)
    expect(merchant_data[:data][:attributes][:name]).to eq(merchant.name)
  end

  it "can delete an item"

  it "can handle sad paths for create, get, edit, etc."
end