class V1::ProfileSerializer < ActiveModel::Serializer
  attributes :id, :username, :email, :latitude, :longitude, :joined_events

  has_many :started_events
  has_many :joined_events
end
