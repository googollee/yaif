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
      :trigger_params => {},
      :action => @action,
      :action_params => {} }
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
      @task = Task.create!(@attr)
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

  describe "work flow" do
    before :each do
      module RequestHelper
        class << self
          def direct_request(method, uri, body, meta={})
            $method = method
            $uri = uri
            $body = body
            $meta = meta

            {}.to_json
          end
        end
      end

      @task = Task.create!(@attr)
    end

    it "should do action" do
      @task.run

      $method.should == :post
      $uri.should == "http://test/action"
      $body.should == "abc"
      $meta.should == nil
    end

    it "should add run count" do
      @task.run
      @task.reload
      @task.run_count.should == 1
      @task.run
      @task.reload
      @task.run_count.should == 2
    end

    it "should update last run time" do
      @task.run
      @task.reload
      last_run = @task.last_run
      @task.run
      @task.reload
      @task.last_run.should > last_run
    end
  end
end
