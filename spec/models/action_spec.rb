require 'spec_helper'

describe Action do
  describe "create" do
    before :each do
      @service = Factory(:service)
      @attr = { :name => "action",
                :description => "a test action",
                :uri => "http://test",
                :service => @service,
                :do => "puts 'a'" }
    end

    it "should valid" do
      action = Action.new(@attr)
      action.valid?.should be_true
    end

    describe "fail" do
      after :each do
        action = Action.new(@attr)
        action.valid?.should be_false
      end

      it "should fail with empty name" do
        @attr[:name] = ""
      end

      it "should fail without service" do
        @attr[:service] = nil
      end

      it "should fail without do" do
        @attr[:do] = ""
      end

      it "should fail without uri" do
        @attr[:uri] = ""
      end
    end
  end

  describe "with instance" do
    before :each do
      @service = Factory(:service)
      @attr = { :name => "action",
                :description => "a test action",
                :uri => "http://test",
                :service => @service,
                :do => "'a'",
      }
      @action = Action.new(@attr)
    end

    it "should have right service" do
      @action.service.should == @service
    end
  end
end
