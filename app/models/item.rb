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
end