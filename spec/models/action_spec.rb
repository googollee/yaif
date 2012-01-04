require 'spec_helper'

describe Action do
  before :each do
    @service = Factory(:service)
    @attr = { :name => "test action",
              :description => "a test action",
              :http_type => "direct",
              :http_method => "post",
              :in_keys => [:id, :content],
              :target => 'http://test/action/#{id}',
              :header => { "Content-Type" => "appplication/xml" },
              :body => '"#{content}"',
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
          end
        end
      end

      @action = Action.new(@attr)
      @meta = Factory(:service_meta_with_user, :service => @action.service, :data => {:pass => "xyz"})
      @user = @meta.user
    end

    it "should parse symbol in meta data" do
      params = { :updated => Time.now, :id => "123", :content => "abc" }
      @action.target = 'http://test/action/#{pass}'
      @action.send_request @user, params
      $uri.should == "http://test/action/xyz"
    end

    it "should send request" do
      params = { :updated => Time.now, :id => "123", :content => "abc" }
      @action.send_request @user, params
      $method.should == @attr[:http_method].to_sym
      $uri.should == "http://test/action/123"
      $body.should == "abc"
      $meta[:pass].should == "xyz"
      $meta[:header].should == @attr[:header]
    end

    it "should call service when not find method" do
      service = Factory(:service, :helper => "
                          def test_helper(a)
                            a.to_s
                          end")
      meta = Factory(:service_meta_with_user,
                     :service => service,
                     :user => @user,
                     :data => {})
      @attr[:body] = "test_helper(1)"
      @attr[:service] = service
      @action = Action.new(@attr)
      @action.send_request @user, :updated => Time.now, :id => "123"
      $body.should == "1"
    end

    it "should raise error when no meta" do
      service = Factory(:service)
      @attr[:service] = service
      @action = Action.new(@attr)
      lambda do
        @action.send_request(@user, {})
      end.should raise_error
    end

    it "should ignore empty content when sending request" do
      $body = 'not run'
      @action.send_request @user, { :updated => Time.now, :id => '123', :content => '' }
      $body.should == 'not run'
    end
 end
end
