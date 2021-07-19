class Order < ApplicationRecord
  alias_attribute :line_items, :order_line_items

  belongs_to :stop, optional: true
  belongs_to :location, optional: true
  has_many :order_line_items, dependent: :destroy
  accepts_nested_attributes_for :order_line_items

  attr_accessor :enable_validation

  validate :validate_stop_and_location, on: :update, if: lambda{ |object| object.enable_validation.present? }

  def validate_stop_and_location
    if location.present? && !location.is_active?
      errors.add(:location_id, "The selected location is inactive!")
    end
    if stop.present? && stop.draft?
      errors.add(:stop_id, "The selected stop is set as draft!")
    end
  end

  FULFILLMENT = [
                  ['All', 'all'],
                  ['Fulfilled', 'fulfilled'],
                  ['Unfulfilled', 'unfulfilled']
                ].freeze
  EXCLUDE = [
              ['Cancelled', "cancelled"],
              ['Refunded', 'refunded']
            ]

  SHOPIFY_ATTRIBUTES =  {
                          sh_location_id: :location_id,
                          sh_stop_id: :stop_id,
                          sh_location: [:location, :name],
                          sh_address: [:location, :address],
                          sh_coordinates: [:location, :float_coordinates],
                          sh_date_time:  [:stop, :date_start_end]
                        }

  CHANGES_ATTRIBUTES  = {
                          sh_location: [:location, :name],
                          sh_date_time:  [:stop, :date_start_end],
                          sh_address: [:location, :address],
                          sh_coordinates: [:location, :float_coordinates]
                        }

  MAPPER_ATTRIBUTES =  {
                          "{{ customer_name }}" => [:customer, :full_name],
                          "{{ location_address }}" => [:location, :address],
                          "{{ location_name }}" => [:location, :name],
                          "{{ order_number }}"  => :order_number,
                          "{{ order_id }}"      => :order_id,
                          "{{ order_details }}" => :all_line_items,
                          "{{ location_date }}" => [:stop, :date_start_end]
                        }

  HUMANIZE_CHANGES_ATTRIBUTES = { sh_location: "Location",
                                  sh_date_time: "Date&Time",
                                  sh_address: "Address",
                                  sh_coordinates: "Coordinates"}.with_indifferent_access

  GENERAL_INFO =  {
                    :name => "*** GENERATED INFORMATION ***",
                    :value => "*** DO NOT EDIT HERE ***"
                  }

  scope :mismatched, -> { where(is_mismatched: true) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }
  scope :migrated, -> { where.not(migrated_order_id: nil) }
  scope :active, -> {where(cancelled_at: nil).where.not(financial_status: "refunded")}

  def send_chain(methd)
    if methd.is_a?(Array)
      [methd].flatten.inject(self, :try)
    else
      send(methd)
    end
  end

  def all_line_items
    li = []
    line_items.each do |l|
      li << "#{l.quantity} x #{l.title}"
    end
    li.join(", ")
  end

  def all_line_items_w_price
    li = []
    line_items.each do |l|
      li << "#{l.quantity} x #{l.title} ($#{l.price})"
    end
    li.join(", ")
  end

  def line_items_total
    line_items.sum(:price)
  end

  def total_boxes
    total = 0
    line_items.each do |li|
      next unless li.product_id.in?(Product.box_ids + Product.special_ids)
      total += li.quantity * (li.product.qty || 1)
    end
    total
  end

  def total_pecans
    total = 0
    line_items.each do |li|
      next unless li.product_id.in?(Product.pecan_ids + Product.special_ids)
      total += li.quantity * (li.product.qty || 1)
    end
    total
  end

  def total_books
    total = 0
    line_items.each do |li|
      next unless li.product_id.in?(Product.book_ids)
      total += li.quantity * (li.product.qty || 1)
    end
    total
  end

  def canceled?
    self.cancelled_at.present?
  end

  def fulfillment_text
    return "UNFULFILLED" unless fulfillment_status.present?
    "FULFILLED"
  end

  def mismatches
    mismatches = {}
    SHOPIFY_ATTRIBUTES.each do |s_attr, attr|
      if self.send_chain(s_attr) != self.send_chain(attr) && (s_attr != :sh_coordinates || self.send_chain(s_attr) != self.send_chain([:location, :coordinates]))
        mismatches[s_attr] = {sh: self.send_chain(s_attr), db: self.send_chain(attr)}
      end
    end
    mismatches
  end


  def update_sh_attributes
    order_attrs = {}
    SHOPIFY_ATTRIBUTES.each do |s_attr, attr|
      order_attrs[s_attr] = self.send_chain(attr)
    end
    self.assign_attributes(order_attrs)
    self.is_mismatched = false
    self.save
  end

  def location_changes
    t_changes = []
    CHANGES_ATTRIBUTES.each do |s_attr, attr|
      if self.send_chain(s_attr) != self.send_chain(attr)
        t_changes << "#{self.send_chain(s_attr)} -to- #{self.send_chain(attr)}"
      else
        t_changes << "-"
      end
    end
    t_changes
  end

  def get_mapped_value key
    property = MAPPER_ATTRIBUTES[key]
    self.send_chain(property)
  end

  def qr_code_url
    "#{ENV["QR_CODE_URL"]}#{self.order_id}"
  end

  def all_details
    attributes.merge({
      "email" => customer.email,
      "line_item" => all_line_items,
      "pickup_date_time" => stop&.date_start_end,
      "pickup_address" => location&.address,
      "pickup_location" => location&.name,
      "first_name" => customer.first_name,
      "last_name" => customer.last_name,
    })
  end

  def parsed_coordinates
    if scanned_coordinates.present?
      begin
        coord = scanned_coordinates.gsub("=>", ":")
        coord = JSON.parse coord
      rescue Exception => e
        nil
      end
    end
  end

  def shopify_note_attributes
    {
      '*** GENERATED INFORMATION ***' => '*** DO NOT EDIT HERE ***',
      'order-type' => 'preorder',
      'tour-id' => location_id,
      'Location' => location&.name,
      'Location Address' => location&.address,
      'location-coordinate' => location&.coordinates,
      'Location Date/Time' => stop&.date_start_end,
      'tour-date-id' => stop_id
    }
  end

  def line_item_attributes
    line_items_array = []

    line_items.each do |line_item|
      product = Product.find_by_product_id(line_item.product_id)
      line_items_array << {variant_id: product.variant_id, quantity: line_item.quantity}
    end

    line_items_array
  end

  # THIS IS JUST FOR LOAD TEST
  def shopify_attributes
    {
      :email => customer&.email,
      :phone => customer&.phone_number,
      :line_items => shopify_line_items_attrs,
      :customer => {
        :first_name => customer.first_name,
        :last_name => customer.last_name,
        :email => customer.email
      },
      :financial_status => financial_status,
      :note_attributes => shopify_note_attributes,
      :tags => "preordersummer_2021",
    }
  end



  def shopify_line_items_attrs
    [
      {
        :quantity => 1,
        :variant_id => 37404335177915
      }
    ]
  end

end
