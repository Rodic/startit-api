class V1::EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start_latitude, :start_longitude, :start_time, :type

  has_one :creator
end
