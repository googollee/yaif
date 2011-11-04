require 'spec_helper'
require 'time'

$entries = 5.times.inject([]) do |o, n|
  o << { :title => "entry-#{n}",
         :updated => "2011-11-1 16:5#{n}:00",
         :link => "http://test/" }
end

describe Trigger do
  before :each do
    @service = Factory(:service)
    @attr = { :name => "test trigger",
              :description => "a test trigger",
              :http_type => "direct",
              :http_method => "get",
              :in_keys => [:user_id],
              :source => 'http://test/trigger/#{user_id}',
              :out_keys => [:title, :link],
              :content_to_hash => '
                require "time"
                json = ActiveSupport::JSON.decode(content)
                json.each.inject([]) do |o, i|
                  o << { :title => i["title"],
                         :updated => Time.parse(i["updated"]),
                         :link => i["link"],
                         :id => user_id }
                end
              ',
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
      task1 = Factory(:task, :trigger => @trigger)
      task2 = Factory(:task, :trigger => @trigger)
      @trigger.tasks.should == [task1, task2]
    end

    it "should respond of content_to_atom" do
      @trigger.respond_to?(:get_atom).should be_true
    end
  end

  describe "workflow" do
    before :each do
      module RequestHelper
        class << self
          def direct_request(method, uri, body, meta={})
            $method = method
            $uri = uri
            $body = body
            $meta = meta

            $entries.to_json
          end
        end
      end

      @trigger = Trigger.new(@attr)
      @meta = Factory(:service_meta_with_user,
                      :service => @trigger.service,
                      :data => { :pass => "xyz" })
      @user = @meta.user
    end

    it "should get right atom content" do
      ret = @trigger.get_atom @user, :user_id => 123

      $method.should == @trigger.http_method.to_sym
      $uri.should == "http://test/trigger/123"
      $body.should == ""
      $meta[:pass].should == "xyz"
      5.times do |n|
        ret[n][:title].should == $entries[n][:title]
        ret[n][:link].should == $entries[n][:link]
        ret[n][:updated].should == Time.parse($entries[n][:updated])
        ret[n][:id].should == 123
      end
    end

    it "should call service when not find method" do
      service = Factory(:service, :helper => "
                          def test_helper(a)
                            a.to_s
                          end")
      @attr[:content_to_hash] = "test_helper(1)"
      @attr[:service] = service
      @trigger = Trigger.new(@attr)
      @trigger.get_atom(@user, { :user_id => "123" }).should == "1"
    end
  end
end
