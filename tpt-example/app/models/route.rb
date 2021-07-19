class Route < ApplicationRecord
  has_many :route_dates, dependent: :destroy
  has_and_belongs_to_many :users
  belongs_to :tour
  accepts_nested_attributes_for :route_dates, allow_destroy: true
  validates_presence_of :name
end
