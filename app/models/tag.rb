class Tag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  validates :name, presence: true
  validates :color, presence: true
  validates :name, uniqueness: { scope: :user_id, message: 'already exists for this user' }

  scope :required, -> { where(is_required: true) }
  scope :for_user, ->(user) { where(user: user).or(required) }

  def required?
    is_required?
  end
end
