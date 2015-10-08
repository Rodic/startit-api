class V1::ProfileSerializer < ActiveModel::Serializer
  attributes :id, :username, :email, :latitude, :longitude

  has_many :created_events
end
