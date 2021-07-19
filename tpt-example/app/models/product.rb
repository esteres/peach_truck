class Product < ApplicationRecord
  has_many :draft_order_line_items

  enum product_type: [:box, :pecan, :book, :special, :other]

  def self.product_types
    [:box, :pecan, :book, :special, :other]
  end

  def self.box_ids
    Thread.current[:box_ids] ||= self.box.pluck(:product_id)
  end

  def self.pecan_ids
    Thread.current[:pecan_ids] ||= self.pecan.pluck(:product_id)
  end

  def self.book_ids
    Thread.current[:book_ids] ||= self.book.pluck(:product_id)
  end

  def self.special_ids
    Thread.current[:special_ids] ||= self.special.pluck(:product_id)
  end

  def self.other_ids
    Thread.current[:other_ids] ||= self.other.pluck(:product_id)
  end

  def self.quantities
    self.product_types.map { |product_type| [product_type.to_s, 0] }.to_h.merge(
      self.select(:product_type, :qty).map do |product|
        [product.product_type, product.qty]
      end.to_h
    )
  end

end
