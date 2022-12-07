class Item < ApplicationRecord
  validates :name, :description, :merchant_id, presence: true
  validates :unit_price, presence: true, numericality: true 
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  after_destroy :delete_empty_invoices

  def delete_empty_invoices
    empty_invoices = Invoice.empty_invoices
    empty_invoices.each { |invoice| Invoice.delete(invoice.id) }
  end

  def self.search_by_name(search_params)
    where("name ILIKE ?", "%#{search_params}%").order(:name)
  end

  def self.search_by_price(min, max)
    if min == nil 
      # do stuff
      where("unit_price < ?", "#{max}").order(:name)
    elsif max == nil 
      # do other stuff 
      where("unit_price > ?", "#{min}").order(:name)
    else
      # do it all baby
      where("? < unit_price < ?", "#{min}", "#{max}").order(:name)
    end
  end
end