require 'spec_helper'

describe Trigger do
  before :each do
    @service = Factory(:service)
    @attr = { :name => "test trigger",
              :description => "a test trigger",
              :http_type => "direct",
              :http_method => "get",
              :params => nil,
              :source => "http://test/trigger",
              :content_to_atom => "content",
              :service => @service }
  end

  describe "create" do
    it "should valid" do
      trigger = Trigger.new(@attr)
      trigger.valid?.should be_true
    end

    describe "fail" do
      after :each do
        trigger = Trigger.new(@attr)
        trigger.valid?.should be_false
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
      @trigger = Trigger.new(@attr)
    end

    it "should have right service" do
      @trigger.service.should == @service
    end

    it "should have right task" do
      user = Factory(:user, :email => "asdf@sa.com")
      action = Factory(:action, :service => @service)
      task1 = Factory(:task, :user => user, :trigger => @trigger, :action => action)
      task2 = Factory(:task, :user => user, :trigger => @trigger, :name => "task2", :action => action)
      @trigger.tasks.should == [task1, task2]
    end
  end
end
