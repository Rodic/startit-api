class Event < ActiveRecord::Base

  validates_presence_of     :start_latitude, :start_longitude, :start_time, :description, :type
  validates_numericality_of :start_latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90
  validates_numericality_of :start_longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180
  validates_length_of       :description, maximum: 500
  validates_length_of       :title, maximum: 150
  validates_inclusion_of    :type, in: %w( Run BikeRide ), message: "must be 'Run' or 'BikeRide'"
  validate                  :start_time_cannot_be_in_the_past

  before_validation :save_start_time_utc

  belongs_to :creator, class_name: User

  def start_time_cannot_be_in_the_past
    # unless lat and lon are provided timezone is unknown and start_time_utc is blank
    # in that case we assume start_time is in UTC and we use it to determine is date in the past
    time = start_time_utc || start_time
    errors.add(:start_time, "can't be in the past") if time && time < Time.now
  end

  default_scope { includes(:creator) }

  scope :upcoming, -> { where('start_time_utc >= ?', Time.now) }

  def save_start_time_utc
    return unless self.start_latitude && self.start_longitude
    if Rails.env == "test"
      self.start_time_utc = start_time - 2.hours if start_time
    else
      # Get timezone from lat and lon
      timezone = (Timezone::Zone.new :latlon => [self.start_latitude, self.start_longitude])
      self.start_time_utc = timezone.local_to_utc(self.start_time)
    end
  end

end
