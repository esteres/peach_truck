class Tour < ApplicationRecord
  has_many :region_tours
  has_many :regions, through: :region_tours
  has_many :routes

  accepts_nested_attributes_for :regions, reject_if: :all_blank, allow_destroy: true

  def stops(dates = nil, market_id = nil)
    result = unless market_id.present?
       Stop.joins(location: { market: { region: :tours } }).where(tours: { id: self.id })
      .select(:id, :date, :location_id, :start_time, :end_time, :max_boxes)
    else
      Stop.joins(location: { market: { region: :tours } }).where(tours: { id: self.id }, locations: {market_id: market_id} )
      .select(:id, :date, :location_id, :start_time, :end_time, :max_boxes)
    end
    result = result.where(date: dates) if dates.present?
    result
  end

  def formatted_date
    start_date&.strftime('%m/%d/%Y')
  end
end
