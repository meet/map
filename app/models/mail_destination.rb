# Represents an email forwarding address.
class MailDestination
  
  include ActiveModel::Validations
  extend ActiveModel::Translation
  
  validates_presence_of :mail_destination_inbox
  validates_inclusion_of :mail_destination_inbox, :in => ["true", "false"]
  
  attr_accessor :mail_destination_inbox
  
  def initialize(user, attributes = {})
    @mail_destination_inbox = user.mail_destination_inbox
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
