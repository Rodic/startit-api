class V1::ProfileSerializer < ActiveModel::Serializer
  attributes :id, :username, :email, :latitude, :longitude

  has_many :started_events
end
