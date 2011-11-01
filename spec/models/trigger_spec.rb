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
              :params => nil,
              :source => "http://test/trigger",
              :out_keys => "title, link",
              :content_to_hash => '
                require "time"
                json = ActiveSupport::JSON.decode(content)
                json.each.inject([]) do |o, i|
                  o << { :title => i["title"],
                         :updated => Time.parse(i["updated"]),
                         :link => i["link"] }
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

    it "should get right atom content" do
      module RequestHelper
        class << self
          def direct_request(method, uri, body, header=nil)
            $entries.to_json
          end
        end
      end

      ret = @trigger.get_atom
      5.times do |n|
        ret[n][:title].should == $entries[n][:title]
        ret[n][:link].should == $entries[n][:link]
        ret[n][:updated].should == Time.parse($entries[n][:updated])
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
      @trigger.get_atom.should == "1"
    end
  end
end
