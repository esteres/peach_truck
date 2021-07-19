class RegionTour < ApplicationRecord
  belongs_to :tour
  belongs_to :region
end
