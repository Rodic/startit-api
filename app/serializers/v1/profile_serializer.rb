class V1::ProfileSerializer < ActiveModel::Serializer
  attributes :id, :username, :email, :latitude, :longitude, :joined_events

  has_many :started_events, serializer: V1::EventSerializer
  has_many :joined_events, serializer: V1::EventSerializer
end
