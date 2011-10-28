require 'spec_helper'

describe Action do
  before :each do
    @service = Factory(:service)
    @attr = { :name => "test action",
              :description => "a test action",
              :http_type => "direct",
              :http_method => "post",
              :params => nil,
              :source => "http://test/action",
              :body => '"abc"',
              :service => @service }
  end

  describe "create" do
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

      it "should fail without http_type" do
        @attr[:http_type] = ""
      end

      it "should fail without http_method" do
        @attr[:http_method] = ""
      end

      it "should fail without source" do
        @attr[:source] = ""
      end
    end
  end

  describe "with instance" do
    before :each do
      @action = Action.new(@attr)
    end

    it "should have right service" do
      @action.service.should == @service
    end
  end
end
