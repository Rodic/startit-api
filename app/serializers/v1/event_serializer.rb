class V1::EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start_latitude, :start_longitude, :start_time, :type

  has_one :creator

  has_many :participants

  def start_time
    object.start_time.strftime("%Y %h %d %H:%M:%S")
  end
end
