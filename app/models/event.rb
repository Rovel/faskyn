class Event < ActiveRecord::Base
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"

  validates :sender, presence: true
  validates :title, presence: { message: "can't be blank" }
  # before_validation(on: :create) do
  #   self.start_at = DateTime.strptime(self.start_at, '%m/%d/%Y %I:%M %p').to_datetime.utc
  #   self.end_at = DateTime.strptime(self.end_at, '%m/%d/%Y %I:%M %p').to_datetime.utc
  # end
  #validates :executor, presence: { message: "must be valid"}
  #validates :content, presence: { message: "can not be blank" }, length: { maximum: 140, message: "can't be longer than 140 characters" }

  scope :between_time, -> (start_time, end_time) do
    where("? < start_at < ?", Event.format_date(start_time), Event.format_date(end_time))
  end
  scope :allevents, -> (u) { where('sender_id = ? OR recipient_id = ?', u.id, u.id) }
  scope :between, -> (sender_id, recipient_id) do
    where("(events.sender_id = ? AND events.recipient_id = ?) OR (events.sender_id = ? AND events.recipient_id = ?)", sender_id, recipient_id, recipient_id, sender_id)
  end

  def self.format_date(date_time)  
   Time.at(date_time.to_i).to_formatted_s(:db)  
  end

  def as_json(options = {})
    unless self.start_at.nil? || self.end_at.nil?
      { id: self.id,
        recipientId: self.recipient_id,
        recipientName: self.recipient.profile.full_name,
        senderId: self.sender_id,
        senderName: self.sender.profile.full_name,
        title: self.title,
        body: self.body || "",
        start: start_at.rfc822,
        :end => end_at.rfc822,
        allDay: self.all_day,
        recurring: false 
        #url: Rails.application.routes.url_helpers.user_event_path(self)
      }
    end
  end

  def event_name_company
    [recipient.try(:profile).try(:first_name), recipient.try(:profile).try(:last_name), recipient.try(:profile).try(:company)].join(' ')
  end

  def event_name_company=(name)
    self.recipient = User.joins(:profile).where("CONCAT_WS(' ', first_name, last_name, company) LIKE ?", "%#{name}%").first if name.present?
  rescue ArgumentError
    self.recipient = nil
  end
end
