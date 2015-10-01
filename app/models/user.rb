class User < ActiveRecord::Base

  # matcher taken from: http://www.regular-expressions.info/email.html
  EMAIL_MATCHER = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i

  validates_presence_of     :provider, :uid, :username
  validates_inclusion_of    :provider, in: %w( facebook ), message: "must be on of the following: 'facebook'"
  validates_numericality_of :latitude,  greater_than_or_equal_to: -90,  less_than_or_equal_to: 90,  unless: "latitude.blank?"
  validates_numericality_of :longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180, unless: "longitude.blank?"
  validates_format_of       :email, with: EMAIL_MATCHER, message: "invalid format", unless: "email.blank?"
end
