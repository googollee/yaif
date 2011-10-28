require 'spec_helper'

describe Service do
  describe "create" do
    before :each do
      @attr = { :name => "TestService",
                :icon => "file://./test.png",
                :description => "a test service",
                :auth_type => "none_auth",
                :auth_data => {} }
    end

    it "should success with right attr" do
      service = Service.new(@attr)
      service.valid?.should be_true
    end

    it "should fail with empty or too long name" do
      @attr[:name] = ""
      service = Service.new(@attr)
      service.valid?.should be_false
    end

    it "should fail with empty auth_type" do
      @attr[:auth_type] = ""
      service = Service.new(@attr)
      service.valid?.should be_false
    end

    it "should success with hash auth_data" do
      @attr[:auth_data] = { :key => "some key",
                            :secret => "any secret" }
      service = Service.new(@attr)
      service.valid?.should be_true
    end
   end

  describe "with instance" do
    before :each do
      @attr = { :name => "TestService",
                :icon => "file://./test.png",
                :description => "a test service",
                :auth_type => "none_auth",
                :auth_data => {} }
      @service = Service.new(@attr)
      @trigger = Factory(:trigger, :service => @service)
      @action = Factory(:action, :service => @service)
    end

    it "should have right triggers" do
      trigger = Factory(:trigger, :name => "another tirgger", :service => @service)
      @service.triggers.should == [@trigger, trigger]
    end

    it "should have right actions" do
      action = Factory(:action, :name => "another action", :service => @service)
      @service.actions.should == [@action, action]
    end
  end
end
