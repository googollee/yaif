require 'digest/md5'

class RegKey < ActiveRecord::Base
  validates :key, :presence => true
  validates :email, :presence => true

  def self.check_validate email
    key = self.find_by_email email
    key.validate
  end

  def initialize params
    params[:key] = Digest::MD5.hexdigest("#{Time.now}#{params[:email]}")
    super params
  end

  def validate?
    validation != 0
  end

  def validate
    return false if not validate?
    self.validation = 0
    save
    true
  end
end
