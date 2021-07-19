class OrderLineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product, primary_key: :product_id, optional: true
  before_create :check_duplicates

  def check_duplicates
    obj = OrderLineItem.where(order_id: self.order_id, product_id: self.product_id).first
    if obj.present?
      obj.destroy
    end
  end

  def product_type
    Product.product_types.find do |product_type|
      self.product_id.in?(Product.send(:"#{product_type}_ids"))
    end&.to_s
  end
end
