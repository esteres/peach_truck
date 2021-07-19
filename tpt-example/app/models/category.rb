class Category < ApplicationRecord
	has_many :location_categories
	has_many :locations, through: :location_categories

  def details
    self.attributes.slice(
      "id",
      "name",
    ).merge(
      "special_pin" => self.special_pin,
    )
  end

  def special_pin
    result = self.name.strip.titleize.downcase.gsub(" ", "-")
    result if result.in?(["hotel", "cold-storage"])
  end
end
