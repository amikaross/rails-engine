class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items

  def self.empty_invoices 
    self.left_joins(:invoice_items)
        .group(:id)
        .select("invoices.*, count(invoice_items.*) as count")
        .having("invoice_items.count = 0")
  end
end