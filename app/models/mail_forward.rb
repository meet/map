# Represents an email forwarding address.
class MailForward
  
  include ActiveModel::Validations
  extend ActiveModel::Translation
  
  validates_presence_of :mail
  validates_format_of :mail, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  attr_accessor :mail
  
  def initialize(user, attributes = {})
    @mail = user.mail_forward
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  # ActiveRecord methods
  
  def persisted?
    true
  end
  
  def to_key
    nil
  end
  
end
