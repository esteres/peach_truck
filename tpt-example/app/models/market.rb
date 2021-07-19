class Market < ApplicationRecord
  belongs_to :region
  has_many :locations

  before_create :set_position
  after_destroy :fix_positions
  before_destroy :remove_market_from_locations

  validates_presence_of :name

  def key
    "market_#{self.id || 'all'}"
  end

  def set_position
    self.position = Market.count
  end

  def fix_positions
    Market.order('position asc').all.each_with_index do |page, index|
      page.update_attribute(:position, index) unless page.position == index
    end
  end

  def remove_market_from_locations
    locations.each do |location|
      location.update_columns(market_id: nil, market_position: nil)
    end
  end
end
