class Task < ActiveRecord::Base
  belongs_to :assigner, class_name: "User"
  belongs_to :executor, class_name: "User"
  validates :assigner_id, presence: true
  validates :executor_id, presence: { message: "can not be blank" }
  validates :content, presence: { message: "can not be blank" }, length: { maximum: 140, message: "can't be longer than 140 characters" }

  scope :completed, -> { where.not(completed_at: nil) }
  scope :uncompleted, -> { where(completed_at: nil) }
  scope :alltasks, -> (u) { where('executor_id = ? OR assigner_id = ?', u.id, u.id) }

  #self.per_page = 12

  def completed?
    !completed_at.blank?
  end

=begin
  def indextasks
    indextasks = []
    indextasks << @assigned_tasks.uncompleted
    indextasks << @expired_tasks.uncompleted
    indextasks.sort_by { |h| h[:created_at] }.reverse!
  end
=end
end
