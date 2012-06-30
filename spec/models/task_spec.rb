require 'spec_helper'

describe Task do
  before :each do
    @user = FactoryGirl.create(:user)
    @trigger = FactoryGirl.create(:trigger)
    @action = FactoryGirl.create(:action)
    @attr = {
      :name => "test task",
      :user => @user,
      :trigger => @trigger,
      :trigger_params => {},
      :action => @action,
      :action_params => {}
    }
  end

  describe "create" do
    it "should success with right attr" do
      task = Task.new(@attr)
      task.valid?.should be_true
    end

    it "should use current time as last run initialize value" do
      task = Task.new(@attr)
      task.save
      task.last_run.should_not == nil
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
      @trigger_meta = FactoryGirl.create(:service_meta_with_user, :user => @user, :service => @trigger.service, :data => { :from => "trigger" })
      @action_meta = FactoryGirl.create(:service_meta_with_user, :user => @user, :service => @action.service, :data => { :from => "action" })
      $content = [
        {:title => "1", :published => 2.day.ago},
        {:title => "2", :published => 1.minute.ago}
      ]
      module RequestHelper
        class << self
          def direct_request(method, uri, body, meta={})
            $method = method
            $uri = uri
            $body = body
            $meta = meta

            $content.to_json
          end
        end
      end

      @task = Task.create!(@attr)
    end

    it "should filter the published date" do
      @task.last_run = 1.day.ago
      @task.save
      @task.filter_items $content do |item|
        item[:title].should == "2"
      end
    end

    it "should filter with asc order" do
      content = [
        {:title => "1", :published => 2.day.ago},
        {:title => "2", :published => 1.minute.ago},
      ]
      order = [ "1", "2" ]
      i = 0
      @task.filter_items content do |item|
        item[:title].should == order[i]
        i += 1
      end

      content = [
        {:title => "2", :published => 1.minute.ago},
        {:title => "1", :published => 2.day.ago},
      ]
      order = [ "1", "2" ]
      i = 0
      @task.filter_items content do |item|
        item[:title].should == order[i]
        i += 1
      end
    end

    it "should add run count" do
      @task.last_run = 3.days.ago

      @task.run
      @task.reload
      @task.run_count.should == 2

      @task.last_run = 1.day.ago
      @task.run
      @task.reload
      @task.run_count.should == 3

      @task.run
      @task.reload
      @task.run_count.should == 3
    end

    it "should update last run time" do
      @task.last_run = 3.day.ago
      @task.run
      @task.reload
      @task.last_run.day.should == 1.minute.ago.day
      $content << {:title => "3", :published => 0.day.ago}
      @task.run
      @task.reload
      @task.last_run.day.should == 0.day.ago.day
    end

    it "should update last run even if last run initial with nil" do
      @task.last_run = nil
      @task.save
      @task.run
      @task.last_run.day.should == 0.day.ago.day
    end

    it "should update last run time even if no published data" do
      $content = [{:title => "1"}]
      @task.trigger.content_to_hash = <<EOF
        parse_json content do |i|
          { :title => i["title"] }
        end
EOF
      @task.trigger.save

      @task.last_run = 3.day.ago
      @task.run
      @task.reload
      @task.last_run.day.should == 0.day.ago.day
    end

    it "should save error message when run failed" do
      module RequestHelper
        class << self
          def direct_request(method, uri, body, meta={})
            raise "run failed"
          end
        end
      end

      @task.run
      @task.error_log[:message].should =~ /run failed/i
    end
  end

  describe "whole work flow" do
    before :each do
      @trigger = FactoryGirl.create(:trigger, :content_to_hash => "[{:title => 'Just test!', :published => Time.now}]")
      @trigger_meta = FactoryGirl.create(:service_meta_with_user, :user => @user, :service => @trigger.service, :data => { :from => "trigger" })
      @action = FactoryGirl.create(:action, :in_keys => [:content], :body => '"#{content}"')
      @action_meta = FactoryGirl.create(:service_meta_with_user, :user => @user, :service => @action.service, :data => { :from => "action" })

      @attr[:trigger] = @trigger
      @attr[:action] = @action
      @attr[:action_params] = { :content => '#{title}' }

      module RequestHelper
        class << self
          def direct_request(method, uri, body, meta={})
            $method = method
            $uri = uri
            $body = body
            $meta = meta
          end
        end
      end

    end

    it "should do action" do
      @task = Task.create!(@attr)
      @task.last_run = 1.day.ago
      @task.run

      $method.should == :post
      $uri.should == "http://test/action"
      $body.should == "Just test!"
      $meta[:from].should == "action"
    end
  end
end
