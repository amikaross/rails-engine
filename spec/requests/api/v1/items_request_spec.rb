require 'rails_helper'

describe "Items API" do 
  it "gets all items" do 
    create_list(:item, 4)

    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items).to have_key(:data)
    expect(items[:data].count).to eq(4)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)
  
      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)
  
      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_an(Integer)
    end
  end

  it "when getting all items, no error if db is empty, just returns an empty response" do 
    get '/api/v1/items'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants).to have_key(:data)
    expect(merchants[:data]).to be_an(Array)
    expect(merchants[:data].count).to eq(0)
  end

  it "can get one item by its id" do 
    id = create(:item).id

    get "/api/v1/items/#{id}"

    item_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful 

    expect(item_data).to have_key(:data)
    item = item_data[:data]
    expect(item).to be_a(Hash)

    expect(item).to have_key(:attributes)
    expect(item[:attributes]).to be_a(Hash)

    expect(item[:attributes]).to have_key(:name)
    expect(item[:attributes][:name]).to be_a(String)

    expect(item[:attributes]).to have_key(:description)
    expect(item[:attributes][:description]).to be_a(String)

    expect(item[:attributes]).to have_key(:unit_price)
    expect(item[:attributes][:unit_price]).to be_a(Float)

    expect(item[:attributes]).to have_key(:merchant_id)
    expect(item[:attributes][:merchant_id]).to be_an(Integer)
  end

  it "responds with an error if the id is not found" do 
    get "/api/v1/items/1"

    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(response.status).to eq(404)
    expect(merchant).to have_key(:message)
    expect(merchant).to have_key(:errors)
    expect(merchant[:errors].first).to eq("Couldn't find Item with 'id'=1")
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

    expect(Item.all.count).to eq(0)

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    created_item = Item.last

    expect(response).to be_successful
    expect(Item.all.count).to eq(1)

    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "doesn't allow you to create an item for a merchant that doesn't exist" do 
    item_params = {
      name: "value1",
      description: "value2",
      unit_price: 100.99,
      merchant_id: 1
    }

    headers = {"CONTENT_TYPE" => "application/json"}

    expect(Item.all.count).to eq(0)

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    data = JSON.parse(response.body, symbolize_names: true)

    expect(Item.all.count).to eq(0)
    expect(response.status).to eq(404)
    expect(data).to have_key(:message)
    expect(data).to have_key(:errors)
    expect(data[:errors].first).to eq("Couldn't find Merchant with 'id'=1")
  end

  it "ignores any attributes sent which are not allowed" do 
    merchant_id = create(:merchant).id
    item_params = {
      name: "value1",
      description: "value2",
      unit_price: 100.99,
      merchant_id: merchant_id,
      something: "something",
      not_allowed: "not_allowed"
    }

    headers = {"CONTENT_TYPE" => "application/json"}

    expect(Item.all.count).to eq(0)

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    item_data = JSON.parse(response.body, symbolize_names: true)

    created_item = Item.last

    expect(response).to be_successful
    expect(Item.all.count).to eq(1)

    expect(item_data[:data]).to_not have_key(:something)
    expect(item_data[:data]).to_not have_key(:not_allowed)

    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "returns an error if any attribute is missing" do 
    merchant_id = create(:merchant).id
    item_params = {
      description: "value2",
      merchant_id: merchant_id
    }

    headers = {"CONTENT_TYPE" => "application/json"}

    expect(Item.all.count).to eq(0)

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    
    data = JSON.parse(response.body, symbolize_names: true)

    expect(Item.all.count).to eq(0)
    expect(response.status).to eq(400)

    expect(data).to have_key(:message)
    expect(data[:message]).to eq("Record is missing one or more attributes")

    expect(data).to have_key(:errors)
    expect(data[:errors]).to eq(["Name can't be blank", "Unit price can't be blank", "Unit price is not a number"])
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

  it "can delete an item and all associated data" do 
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)
    other_item = create(:item, merchant: merchant)

    invoice_1 = create(:invoice, merchant: merchant)
    invoice_2 = create(:invoice, merchant: merchant)

    InvoiceItem.create(item: item, invoice: invoice_1, quantity: 3, unit_price: item.unit_price)
    InvoiceItem.create(item: item, invoice: invoice_2, quantity: 1, unit_price: item.unit_price)
    InvoiceItem.create(item: other_item, invoice: invoice_2, quantity: 1, unit_price: other_item.unit_price)
  
    expect(Item.count).to eq(2)
    expect(Invoice.count).to eq(2)
    expect(InvoiceItem.count).to eq(3)
    expect(invoice_2.items.count).to eq(2)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(1)
    expect(Invoice.count).to eq(1)
    expect(InvoiceItem.count).to eq(1)
    expect(invoice_2.items.count).to eq(1)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
    expect{Invoice.find(invoice_1.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can return the results of a search for one item by name" do 
    merchant = create(:merchant)
    other_item = merchant.items.create!(name: "Turing", description: "no", unit_price: 10.99)
    one_item = merchant.items.create!(name: "Ring World", description: "no", unit_price: 12.99)
    yet_another_item = merchant.items.create!(name: "Titanium Ring", description: "its a ring", unit_price: 10002.30)

    get "/api/v1/items/find?name=ring"

    item_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item_data).to have_key(:data)
    item = item_data[:data]
    expect(item).to be_a(Hash)

    expect(item).to have_key(:attributes)
    expect(item[:attributes]).to be_a(Hash)

    expect(item[:attributes]).to have_key(:name)
    expect(item[:attributes][:name]).to eq(one_item.name)

    expect(item[:attributes]).to have_key(:description)
    expect(item[:attributes][:description]).to eq(one_item.description)

    expect(item[:attributes]).to have_key(:unit_price)
    expect(item[:attributes][:unit_price]).to eq(one_item.unit_price)

    expect(item[:attributes]).to have_key(:merchant_id)
    expect(item[:attributes][:merchant_id]).to eq(one_item.merchant_id)
  end

  it "can return a list of results for search for items by name" do 
    merchant = create(:merchant)
    other_item = merchant.items.create!(name: "Turing", description: "no", unit_price: 10.99)
    one_item = merchant.items.create!(name: "Ring World", description: "no", unit_price: 12.99)
    yet_another_item = merchant.items.create!(name: "Titanium Ring", description: "its a ring", unit_price: 10002.30)
    fourth_item = merchant.items.create!(name: "Costco", description: "its a ring", unit_price: 10002.30)

    get "/api/v1/items/find_all?name=ring"

    items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(items).to have_key(:data)
    expect(items[:data]).to be_an(Array)
    expect(items[:data].count).to eq(3)
  end

  it "can return the results of a search for one item by price" do 
    merchant = create(:merchant)
    other_item = merchant.items.create!(name: "Turing", description: "no", unit_price: 10.99)
    one_item = merchant.items.create!(name: "Ring World", description: "no", unit_price: 12.99)
    yet_another_item = merchant.items.create!(name: "Titanium Ring", description: "its a ring", unit_price: 8.30)

    get "/api/v1/items/find?min_price=10"

    item_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item_data).to have_key(:data)
    item = item_data[:data]
    expect(item).to be_a(Hash)

    expect(item).to have_key(:attributes)
    expect(item[:attributes]).to be_a(Hash)

    expect(item[:attributes]).to have_key(:name)
    expect(item[:attributes][:name]).to eq(one_item.name)

    expect(item[:attributes]).to have_key(:description)
    expect(item[:attributes][:description]).to eq(one_item.description)

    expect(item[:attributes]).to have_key(:unit_price)
    expect(item[:attributes][:unit_price]).to eq(one_item.unit_price)

    expect(item[:attributes]).to have_key(:merchant_id)
    expect(item[:attributes][:merchant_id]).to eq(one_item.merchant_id)
  end

  it "responds with an empty hash if there is no item which corresponds" do 
    merchant = create(:merchant)
    other_item = merchant.items.create!(name: "Turing", description: "no", unit_price: 10.99)
    one_item = merchant.items.create!(name: "Ring World", description: "no", unit_price: 12.99)
    yet_another_item = merchant.items.create!(name: "Titanium Ring", description: "its a ring", unit_price: 10002.30)

    get "/api/v1/items/find?name=cad"

    item_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item_data).to have_key(:data)
    item = item_data[:data]
    expect(item).to be_a(Hash)
    expect(item).to be_empty

    get "/api/v1/items/find?min_price=200000"

    item_data = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item_data).to have_key(:data)
    item = item_data[:data]
    expect(item).to be_a(Hash)
    expect(item).to be_empty
  end

  it "returns an error if name and min_price/max_price is used" do 
    get "/api/v1/items/find?name=ring&min_price=50"

    data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(400)

    expect(data).to have_key(:message)
    expect(data[:message]).to eq("Invalid query params")

    expect(data).to have_key(:errors)
    expect(data[:errors]).to eq("Name and price can't be queried simultaneously")
  end

  it "returns an error if there is no correct query parameter" do 
    get "/api/v1/items/find"

    data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(400)

    expect(data).to have_key(:message)
    expect(data[:message]).to eq("Invalid query params")

    expect(data).to have_key(:errors)
    expect(data[:errors]).to eq("Name or Price query must exist")    

    get "/api/v1/items/find?merchant_id=1"

    data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(400)

    expect(data).to have_key(:message)
    expect(data[:message]).to eq("Invalid query params")

    expect(data).to have_key(:errors)
    expect(data[:errors]).to eq("Name or Price query must exist")  

    get "/api/v1/items/find?name="

    data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(400)

    expect(data).to have_key(:message)
    expect(data[:message]).to eq("Invalid query params")

    expect(data).to have_key(:errors)
    expect(data[:errors]).to eq("Query cannot be empty")  
  end

  it "returns an error if price is less than zero or if min price is less than max price" do 
    get "/api/v1/items/find?min_price=-2"

    data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(400)

    expect(data).to have_key(:message)
    expect(data[:message]).to eq("Invalid query params")

    expect(data).to have_key(:errors)
    expect(data[:errors]).to eq("Price cannot be less than 0")    

    get "/api/v1/items/find?min_price=40&max_price=10"

    data = JSON.parse(response.body, symbolize_names: true)

    expect(response.status).to eq(400)

    expect(data).to have_key(:message)
    expect(data[:message]).to eq("Invalid query params")

    expect(data).to have_key(:errors)
    expect(data[:errors]).to eq("Max price must be greater than min price")  
  end
end