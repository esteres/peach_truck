class Location < ApplicationRecord
  attr_accessor :has_changes
  attr_accessor :skip_json_build
  attr_accessor :force_rebuild_json
  attribute :selected_year

  belongs_to :market, optional: true
  has_many :stops, dependent: :destroy
  has_many :orders, through: :stops
  has_many :location_categories, dependent: :destroy
  has_many :categories, through: :location_categories
  has_many :orders

  accepts_nested_attributes_for :stops, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :categories, reject_if: :all_blank, allow_destroy: true

  validates_presence_of :name

  scope :active, -> {where(is_active: true)}
  scope :with_mismatches, -> { joins(:orders).where("orders.is_mismatched = true")}

  before_save :set_address_and_coordinates
  after_save :locations_to_json_job
  after_destroy :locations_to_json_job
  before_save :check_changes
  before_destroy :check_relations


  LOCATION_STATUS = [['Active',true],['Inactive',false]]
  DATA_TYPES = [['One Time','one_time'],['Weekly','weekly']]
  TIMEZONES = [['CT','CT'],['ET','ET']]

  def self.match_by_address(address)
    self.where("? = ANY(addresses)", address.strip)
  end

  def self.with_stops(year: nil)
    result = self.includes(:stops)
    if year.present?
      result = result.joins(:stops).where("EXTRACT(YEAR FROM stops.date) = ?", year).to_a
      result.each { |location| location.selected_year = year }
    end
    result
  end

  def is_tour?
    cat = categories.pluck(:name)
    return false unless "Tour".in?(cat)
    true
  end

  def key
    "location_#{self.id}"
  end

  def set_address_and_coordinates(force: false)
    return unless force || self.address_changed?

    begin
      result = Geocode.fetch(self.address)
    rescue CustomExceptions::GeocodeError => e
      raise e if force
      return
    end

    self.formatted_addresses = result[:formatted_addresses]
    self.addresses ||= []
    self.addresses |= [self.address.strip, *self.formatted_addresses]
    self.lat, self.lng = result.values_at(:lat, :lng)

    set_static_map_tempfile
  end

  def set_static_map_tempfile
    tmp = URI.open(Geocode.static_map_url(self))

    named_tmp = Tempfile.new(["static-map-", ".png"])
    named_tmp.binmode
    named_tmp.write(tmp.read)

    self.static_map = named_tmp
  end

  def coordinates
  	"{\"lat\":\"#{lat}\",\"lng\":\"#{lng}\"}"
  end

  def float_coordinates
    "{\"lat\":#{lat},\"lng\":#{lng}}"
  end

  def name_with_city
    return name if address.nil?
    address_chunks = address.split(",").last(3)
    city = address_chunks[0]&.strip
    state_with_code = address_chunks[1]&.strip
    state = state_with_code&.split(" ")&.first

    "#{name} - #{city}, #{state}"
  end

  def selected_stops
    @_selected_stops ||= if self.selected_year
      stops.select { |stop| stop.date.year == self.selected_year.to_i }
    else
      stops
    end
  end

  def select_for_dates
    is_inactive = !is_active? ? "(INACTIVE)" : ""
    "#{id}.#{name}---#{address}#{is_inactive} ||| #{selected_stops.map{ |td| "#{td.options_for_select}"}.join(", ")}"
  end

  def region
    if self.market.present?
      market.region
    end
  end

  def mismatched_orders_count
    orders.mismatched.count
  end

  def check_changes
    stop_changes = stops.any? {|td| td.changed? }
    if stop_changes || changed?
      self.has_changes = true
    else
      self.has_changes = false
    end
  end

  def name_with_id
    "#{id} #{name}"
  end

  def locations_to_json_job
    return if skip_json_build == true
    if has_changes || force_rebuild_json
      LocationsToJsonJob.perform_async
      CalendarLocationsToJsonJob.perform_async
    end
  end
  private

  def check_relations
    if orders.present? || draft_orders.present? || migrated_orders.present? || canceled_orders.present? || location_changes.present?
      errors.add(:base, "Location cannot be deleted because it has some related records(You can deactivate it!)")
      throw(:abort)
    end
  end
end
