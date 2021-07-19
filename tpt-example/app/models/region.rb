class Region < ApplicationRecord

	has_many :markets, dependent: :destroy
  has_many :region_tours
  has_many :tours, through: :region_tours

  accepts_nested_attributes_for :markets, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :region_tours, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true

end
