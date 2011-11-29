require 'digest/md5'

class RegKey < ActiveRecord::Base
  validates :key, :presence => true
  validates :email, :presence => true

  def self.get_validate_by_key key
    # FIXME:
    # I don't know why sqlite can't find the reg_key with key == 'xxx' if I
    # generated key use hexdigest below.
    # So ought to use LIKE here.
    reg_key = self.where("key LIKE '#{key}'")[0]
    return reg_key if reg_key && reg_key.validate?
    nil
  end

  def self.get_validate_by_email email
    reg_key = self.find_by_email(email)
    return reg_key if reg_key && reg_key.validate?
    nil
  end

  def initialize params
    params[:key] = Digest::MD5.hexdigest("#{Time.now}#{params[:email]}")[0..8]
    super params
  end

  def validate?
    validation != 0
  end

  def mark_used
    self.validation = 0
    save
  end
end
