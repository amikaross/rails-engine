require 'rails_helper'
require 'date'

RSpec.describe Item, type: :model do
  describe "Relationships" do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe "Validations" do 
    it {should validate_presence_of(:name) }
    it {should validate_presence_of(:description) }
    it {should validate_presence_of(:merchant_id) }
    it {should validate_presence_of(:unit_price) }
    it {should validate_numericality_of(:unit_price) }

  end

  describe "instance methods" do
    describe "#delete_empty_invoices" do 
      it "after destroying an item, all invoices that only had that item are also destroyed" do 
        merchant = create(:merchant)
        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant)

        customer = create(:customer)
        invoice_1 = create(:invoice, merchant: merchant, customer: customer)
        invoice_2 = create(:invoice, merchant: merchant, customer: customer)
        invoice_3 = create(:invoice, merchant: merchant, customer: customer)

        InvoiceItem.create!(item: item_1, invoice: invoice_1, quantity: 4, unit_price: item_1.unit_price)
        InvoiceItem.create!(item: item_1, invoice: invoice_2, quantity: 4, unit_price: item_1.unit_price)
        InvoiceItem.create!(item: item_2, invoice: invoice_2, quantity: 4, unit_price: item_1.unit_price)
        InvoiceItem.create!(item: item_3, invoice: invoice_3, quantity: 4, unit_price: item_1.unit_price)

        expect(Invoice.all.count).to eq(3)
        expect(Invoice.find(invoice_1.id)).to eq(invoice_1)

        Item.destroy(item_1.id)

        expect(Invoice.all.count).to eq(2)
        expect{Invoice.find(invoice_1.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "class methods" do 
    describe "::search_by_name" do 
      it "returns a collection of items that case-insensitive partial-match the search parameters, in alphabetical order by name" do 
        merchant = create(:merchant)
        item_1 = merchant.items.create!(name: "Turing", description: "no", unit_price: 10.99)
        item_2 = merchant.items.create!(name: "Ring World", description: "no", unit_price: 12.99)
        item_3 = merchant.items.create!(name: "Titanium Ring", description: "its a ring", unit_price: 10002.30)

        items = Item.search_by_name("ring")

        expect(items).to eq([item_2, item_3, item_1])
      end
    end

    describe "::search_by_price" do 
      it "returns a collection of items that meet the numeric search parameters, in alphabetical order by name" do 
        merchant = create(:merchant)
        item_1 = merchant.items.create!(name: "Turing", description: "no", unit_price: 10.99)
        item_2 = merchant.items.create!(name: "Ring World", description: "no", unit_price: 12.99)
        item_3 = merchant.items.create!(name: "Titanium Ring", description: "its a ring", unit_price: 10002.30)

        items = Item.search_by_price(min=30, max=nil)

        expect(items).to eq([item_3])

        items = Item.search_by_price(min=nil, max=11)

        expect(items).to eq([item_1])

        items = Item.search_by_price(min=5, max=15)
        
        expect(items).to eq([item_2, item_1])
      end
    end
  end
end