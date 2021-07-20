class TourSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :season, :start_date
end