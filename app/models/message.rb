class Message < ActiveRecord::Base
  attachment :message_attachment, extension: ["pdf", "doc"]

  belongs_to :conversation
  belongs_to :user

  #validates_presence_of :body, :conversation_id, :user_id
end
