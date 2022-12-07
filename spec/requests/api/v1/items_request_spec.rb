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

  it "can handle sad paths for create, get, edit, etc."
end