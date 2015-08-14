require 'bcrypt'

class User
  include DataMapper::Resource

  attr_reader :password
  attr_accessor :password_confirmation

  property :id,   Serial
  property :email, String, required: true
  property :password_digest, Text
  property :password_token, Text

  # validates_confirmation_of is a DataMapper method specifically there to
  # test passwords; the model WON'T save unless the password matches the
  # confirmation
  validates_confirmation_of :password
  validates_uniqueness_of :email

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def self.authenticate(email, password)
    user = first(email: email)
    if user && BCrypt::Password.new(user.password_digest) == password
      return user
    else
      nil
    end
  end

  def self.reset_password(email)
    user = first(email: email)
    user.password_token = "QWERTYUIOP"
    user.save
  end
end
