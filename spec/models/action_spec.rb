require 'spec_helper'

describe Action do
  before :each do
    @service = Factory(:service)
    @attr = { :name => "test action",
              :description => "a test action",
              :http_type => "direct",
              :http_method => "post",
              :params => nil,
              :target => "http://test/action",
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
        @attr[:target] = ""
      end
    end
  end

  describe "with instance" do
    before :each do
      module RequestHelper
        class << self
          def direct_request(method, uri, body, header=nil)
            $method = method
            $uri = uri
            $body = body
            $header = header
          end
        end
      end

      @action = Action.new(@attr)
    end

    it "should have right service" do
      @action.service.should == @service
    end

    it "should have right task" do
      task1 = Factory(:task, :action => @action)
      task2 = Factory(:task, :action => @action)
      @action.tasks.should == [task1, task2]
    end

    it "should send request" do
      @attr[:body] = "params.to_s"
      params = { :updated => Time.now, :title => "test title", :link => "http://test/link", :comment => "just a test" }
      @action = Action.new(@attr)
      @action.send_request params
      $method.should == @attr[:http_method].to_sym
      $uri.should == @attr[:target]
      $body.should == params.to_s
    end

    it "should call service when not find method" do
      service = Factory(:service, :helper => "
                          def test_helper(a)
                            a.to_s
                          end")
      @attr[:body] = "test_helper(1)"
      @attr[:service] = service
      @action = Action.new(@attr)
      @action.send_request :updated => Time.now
      $body.should == "1"
    end
  end
end
