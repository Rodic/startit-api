class Event < ActiveRecord::Base

  validates_presence_of     :start_latitude, :start_longitude, :start_time, :description
  validates_numericality_of :start_latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90
  validates_numericality_of :start_longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180
  validates_length_of       :description, maximum: 500
  validates_length_of       :title, maximum: 150
  validate                  :start_time_cannot_be_in_the_past

  def start_time_cannot_be_in_the_past
    if start_time.present? && start_time < Time.now
      errors.add(:start_time, "can't be in the past")
    end
  end

end
