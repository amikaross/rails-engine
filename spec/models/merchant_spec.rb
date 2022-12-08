require "rails_helper"

RSpec.describe(Merchant, type: :model) do
  describe("Relationships") do
    it { should(have_many(:items)) }
  end

  describe "class methods" do 
    describe "::search_by_name" do 
      it "returns a collection of merchants that case-insensitive partial-match the search parameters, in alphabetical order by name" do 
        merchant_1 = Merchant.create!(name: "Turing School")
        merchant_2 = Merchant.create!(name: "Ring World")
        merchant_3 = Merchant.create!(name: "Taco Bell")

        expect(Merchant.search_by_name("ring")).to eq([merchant_2, merchant_1])

        expect(Merchant.search_by_name("hat")).to eq([])

        expect(Merchant.search_by_name("el")).to eq([merchant_3])
      end
    end
  end
end