require 'spec_helper'

describe RegKey do
  before :each do
    @attr = {
      :email => "test1@domain.com",
      :validation => 1,
    }
  end

  it "should valid" do
    key = RegKey.new @attr
    key.valid?.should be_true
    key.save

    key = RegKey.new :email => "only@domain.com"
    key.valid?.should be_true
    key.save
  end

  it "should create different key" do
    key1 = RegKey.new @attr
    key1.save!

    @attr[:email] = "test2@domain.com"
    key2 = RegKey.new @attr
    key2.save!

    key1.key.should_not == key2.key
  end

  it "should check valid" do
    key = RegKey.new @attr
    key.should be_validate

    key.validation = 0
    key.should_not be_validate
  end

  it "should do validate and turn to non-validate status" do
    key = RegKey.new @attr
    key.save
    key.validate.should be_true
    key.validate.should be_false
  end

  it "should get user though email" do
    key = RegKey.new @attr
    key.save

    RegKey.get_validate_key(@attr[:key]).should == key
    RegKey.get_validate_key(@attr[:key]).should == nil
  end
end
