class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  after_destroy :delete_empty_invoices

  def delete_empty_invoices
    empty_invoices = Invoice.empty_invoices
    empty_invoices.each { |invoice| Invoice.delete(invoice.id) }
  end
end