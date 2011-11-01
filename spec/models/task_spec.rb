require 'spec_helper'

describe Task do
  before :each do
    @user = Factory(:user)
    @trigger = Factory(:trigger)
    @action = Factory(:action)
    @attr = {
      :name => "test task",
      :user => @user,
      :trigger => @trigger,
      :trigger_params => "",
      :action => @action,
      :action_params => "" }
  end

  describe "create" do
    it "should success with right attr" do
      task = Task.new(@attr)
      task.valid?.should be_true
    end

    describe "fail" do
      after :each do
        task = Task.new(@attr)
        task.valid?.should be_false
      end

      it "should fail without name" do
        @attr[:name] = ""
      end

      it "should fail without user" do
        @attr[:user] = nil
      end

      it "should fail without trigger" do
        @attr[:trigger] = nil
      end

      it "should fail without action" do
        @attr[:action] = nil
      end
    end
  end

  describe "check attributes" do
    before :each do
      @task = Task.new(@attr)
    end

    it "should have right user" do
      @task.user.should == @user
    end

    it "should have right trigger" do
      @task.trigger.should == @trigger
    end

    it "should have right action" do
      @task.action.should == @action
    end
  end
end
