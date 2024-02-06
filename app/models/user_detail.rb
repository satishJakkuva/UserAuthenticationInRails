class UserDetail
  include Mongoid::Document
  include Mongoid::Timestamps
  include BCrypt
  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :password, type: String
  field :primary_phone_number, type: String
  field :authentication_token, type: String
  field :dob, type: DateTime
  field :status, type: String

  validates :first_name, :last_name, presence: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :dob, presence: true
  validates :email, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w(active inactive) }

  has_many :leave_requests, class_name: 'LeaveRequest', inverse_of: :user
  before_save :encrypt_password

  def encrypt_password
    self.password = BCrypt::Password.create(self.password) if self.password.present?
  end
  def generate_authentication_token
    self.authentication_token = SecureRandom.uuid unless self.authentication_token.present?
  end
  
  def authenticate(password)
    stored_password = BCrypt::Password.new(self.password)
    puts "#{stored_password}"
    puts "#{BCrypt::Password.new( self.password)}"
    stored_password == password
  end
  
end
