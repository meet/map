# Represents a new password.
class Password
  
  include ActiveModel::Validations
  extend ActiveModel::Translation
  
  validate do |password|
    if @user.passworded
      errors.add(:current_password, 'incorrect') unless Directory.new.bind(:method => :simple,
                                                                           :username => @user.dn,
                                                                           :password => current_password)
    end
    errors.add(:new_password_confirmation, 'must match') unless new_password == new_password_confirmation
  end
  validates_presence_of :new_password
  validates_length_of :new_password, :minimum => 8
  validates_format_of :new_password, :with => /[^0-9]/, :message => "can't be all numbers"
  validates_format_of :new_password, :with => /[^a-z]/, :message => "can't be all lowercase letters"
  validates_format_of :new_password, :with => /[^A-Z]/, :message => "can't be all uppercase letters"
  
  attr_accessor :current_password, :new_password, :new_password_confirmation
  
  def initialize(user, attributes = {})
    @user = user
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  # Construct a random password.
  def self.random
    (1..8).collect { |i| (rand(122-48+1)+48).chr }.to_s
  end
  
  # ActiveRecord methods
  
  def persisted?
    false
  end
  
  def to_key
    nil
  end
  
end
