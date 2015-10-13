class Participation < ActiveRecord::Base

  self.primary_keys = :user_id, :event_id

  validates_presence_of :user_id, :event_id
  validates_uniqueness_of :user_id, scope: :event_id, message: "has already been registered as a participant"

  belongs_to :user
  belongs_to :event
end
