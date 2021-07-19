class RouteDate < ApplicationRecord
  belongs_to :route, optional: true
  has_many :route_date_stops
  has_many :stops, through: :route_date_stops

  accepts_nested_attributes_for :route_date_stops, allow_destroy: true

  validates :date, presence: true, allow_blank: false, allow_nil: false

  enum status: [:draft, :active]

  attr_accessor :date_changed
end
