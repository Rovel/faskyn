class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_one :profile, dependent: :destroy
  delegate :first_name, to: :profile, allow_nil: true

  has_many :assigned_tasks, class_name: "Task", foreign_key: "assigner_id", dependent: :destroy
  has_many :executed_tasks, class_name: "Task", foreign_key: "executor_id", dependent: :destroy
  has_many :assigned_and_executed_tasks, -> (user) { where('executor_id = ? OR assigner_id = ?', user.id, user.id) }, class_name: 'Task', source: :task

  has_many :conversations, foreign_key: "sender_id", dependent: :destroy

  has_many :messages, dependent: :destroy

  has_many :notifications, dependent: :destroy

  #likely not needed, yet to take it out
  def tasks_uncompleted
    tasks_uncompleted = assigned_tasks.uncompleted.order("deadline DESC")
    tasks_uncompleted += executed_tasks.uncompleted.order("deadline DESC")
    tasks_uncompleted.sort_by { |h| h[:deadline] }.reverse!
  end

  def tasks_completed
    tasks_completed = assigned_tasks.completed.order("created_at DESC")
    tasks_completed += executed_tasks.completed.order("created_at DESC")
    tasks_completed.sort_by { |h| h[:completed_at] }.reverse!
  end

  #code for listing user based on the number of common tasks with current_user
  def assigners_based_on_task_number
    Task.where(executor_id: id).select('assigner_id AS user_id')
  end

  def executors_based_on_task_number
    Task.where(assigner_id: id).select('executor_id AS user_id')
  end

  def relations_sql_based_on_task_number
    "((#{assigners_based_on_task_number.to_sql}) UNION ALL (#{executors_based_on_task_number.to_sql})) AS relations"
  end

  def ordered_relating_users
    User.joins("RIGHT OUTER JOIN #{relations_sql_based_on_task_number} ON relations.user_id = users.id")
      .group(:id)
      .order('COUNT(id) DESC')
  end
  #end of the code for number of common tasks with current_user

  #counting notifications for user; reseting when gets to notifications index page
  def update_new_chat_notifications
    increment!(:new_chat_notification)
  end

  def reset_new_chat_notifications
    update_attributes(new_chat_notification: 0)
  end

  def update_new_other_notifications
    increment!(:new_other_notification)
  end

  def reset_new_other_notifications
    update_attributes(new_other_notification: 0)
  end

  def full_name_for_notifications_from_message
    "#{[self.profile.first_name, self.profile.last_name].join(' ')}"
  end
end
