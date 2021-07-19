class RouteDateStop < ApplicationRecord
  belongs_to :route_date
  belongs_to :stop

  # before_create :check_duplicates

  # def check_duplicates
  #   obj = RouteDateStop.where(route_date_id: self.route_date_id, stop_id: self.stop_id).first
  #   if obj.present?
  #     obj.destroy
  #   end
  # end
end
