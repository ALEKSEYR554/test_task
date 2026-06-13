class User < ApplicationRecord
  has_secure_password

  has_many :tasks, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin user] }

  before_create :generate_auth_token

  def admin?
    role == 'admin'
  end

  private

  def generate_auth_token
    self.auth_token = SecureRandom.hex(20)
  end
end
