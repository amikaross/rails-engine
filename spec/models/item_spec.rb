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

  end
end