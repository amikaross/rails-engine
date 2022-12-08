class Merchant < ApplicationRecord
  has_many :items

  def self.search_by_name(search_params)
    where("name ILIKE ?", "%#{search_params}%").order(:name)
  end
end