require 'digest/md5'

class RegKey < ActiveRecord::Base
  validates :key, :presence => true
  validates :email, :presence => true

  def self.get_validate_key key
    # FIXME:
    # I don't know why sqlite can't find the reg_key with key == 'xxx' if I
    # generated key use hexdigest below.
    # So ought to use LIKE here.
    reg_key = self.where("key LIKE '#{key}'")[0]
    return reg_key if reg_key && reg_key.validate
    nil
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
