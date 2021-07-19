class Stop < ApplicationRecord
  IDENTIFIER_FIELDS = [:location_id, :date, :start_time]

  belongs_to :location, optional: true
  has_many :orders
  has_one :route_date_stop
  has_one :route_date, through: :route_date_stop

  validates_presence_of :start_time, :end_time
  validates :date, presence: true, allow_blank: false, allow_nil: false
  validates_uniqueness_of IDENTIFIER_FIELDS.last, scope: IDENTIFIER_FIELDS[0..-2]
  validates :repeat_until, presence: true, :if => lambda { |o| o.date_type == "weekly" }

  before_destroy :check_relations


  enum status: [:draft, :active]

  def self.with_extra_details(stops, cached_stops_data = {}, common_cache = {})
    stops = stops.includes(route_date: :route, location: [:categories, market: { region: { tours: :routes } }]).to_a
    new_stop_ids = stops.pluck(:id) - cached_stops_data.keys
    common_cache[:order_line_items] ||= OrderLineItem.joins(:order).where(orders: { stop_id: new_stop_ids }).to_a
    common_cache[:quantities] ||= Product.quantities
    stops.map do |stop|
      cached_stops_data[stop.id] ||= stop.with_extra_details(cached_stops_data, common_cache)
    end
  end

  def with_extra_details(cached_stops_data = {}, common_cache = nil)
    @_common_cache = common_cache
    _hash = {}
    _hash["category"] = location&.categories&.first&.details
    _hash["route"]  = route
    _hash["routes"] = stop_routes
    _hash["stock"]  = stock
    _hash["time_diff"] = time_diff
    _hash["formatted_start_time"] = formatted_start_time
    _hash["formatted_end_time"] = formatted_end_time
    _hash["stop_location"] = stop_location
    while cached_stops_data.find { |stop_id, stop_data| stop_data["stop_location"].slice("lat", "lng") == _hash["stop_location"].slice("lat", "lng") } do
      _hash["stop_location"]["lat"] -= 0.00005 if _hash["stop_location"]["lat"].present?
    end
    attributes.merge(_hash)
  end

  def route
    if route_date.present?
      route_date&.route.attributes.slice("id", "name", "color")
    end
  end

  def stop_routes
    location&.region&.tours&.flat_map { |tour| tour.routes.map { |route| route.attributes.slice("color", "id", "name") } }
  end

  def stock
    sold_boxes = total_products(:total_boxes)
    percentage = sold_boxes.to_f / max_boxes.to_f * 100

    {
      sold_boxes: sold_boxes,
      percentage: ActionController::Base.helpers.number_to_percentage(percentage, precision: 0)
    }
  end

  def time_diff
    if start_time.present? && end_time.present?
      (end_time&.to_time - start_time&.to_time) / 1.hours
    end
  end

  def stop_location
    location&.attributes&.slice("address", "name", "lat", "lng")
  end

  def formatted_date
    date&.strftime('%m/%d/%Y')
  end

  def formatted_start_time
    start_time&.strftime("%I:%M %p")
  end

  def formatted_end_time
    end_time&.strftime("%I:%M %p")
  end

  def formatted_start_time=(value)
    self.start_time = begin
      Time.strptime("#{value} +0000", "%I:%M %p %z")
    rescue ArgumentError
      nil
    end
  end

  def formatted_end_time=(value)
    self.end_time = begin
      Time.strptime("#{value} +0000", "%I:%M %p %z")
    rescue ArgumentError
      nil
    end
  end

  def formatted_date_repeat_until
    repeat_until&.strftime('%m/%d/%Y')
  end

  def date_start_end
    "#{formatted_date} | #{formatted_start_time} - #{formatted_end_time} #{timezone}"
  end

  def options_for_select
    st_status = status == "draft" ? "(DRAFT)" : ""
    "#{formatted_date} | #{formatted_start_time} - #{formatted_end_time} #{timezone}#{st_status}"
  end

  def fulfilled_products(product_type=nil)
    total ||= 0
    orders.where(fulfillment_status: "fulfilled").each do |order|
      total += order.send(product_type)
    end
    total
  end

  def overfilled?
    total_products(:total_boxes) >= max_boxes.to_i
  end

  def overfilled_tag
    return "<b class='red-text'>Overfilled</b>" if self.overfilled?
    "Normal"
  end

  def klaviyo_campaing_name reminder
    "#{reminder} for #{id}"
  end

  private

  def check_relations
    if orders.present? || draft_orders.present? || from_migrated_orders.present? || to_migrated_orders.present? || canceled_orders.present?
      throw(:abort)
    end
  end

end
