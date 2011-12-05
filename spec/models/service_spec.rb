require 'spec_helper'

describe Service do
   before :each do
    @attr = { :name => "TestService",
              :icon => "file://./test.png",
              :description => "a test service",
              :auth_type => "test",
              :auth_data => { :auth => "auth" },
              :helper => "
                def test_helper(a)
                  a.to_s
                end
              " }
  end

  describe "create" do
    it "should success with right attr" do
      service = Service.new(@attr)
      service.valid?.should be_true
    end

    it "should fail with empty or too long name" do
      @attr[:name] = ""
      service = Service.new(@attr)
      service.valid?.should be_false
    end

    it "should fail with empty auth_type" do
      @attr[:auth_type] = ""
      service = Service.new(@attr)
      service.valid?.should be_false
    end

    it "should success with hash auth_data" do
      @attr[:auth_data] = { :key => "some key",
                            :secret => "any secret" }
      service = Service.new(@attr)
      service.valid?.should be_true
    end
   end

  describe "with instance" do
    before :each do
      @service = Service.new(@attr)
    end

    it "should have right triggers" do
      trigger1 = Factory(:trigger, :service => @service)
      trigger2 = Factory(:trigger, :service => @service)
      @service.triggers.should == [trigger1, trigger2]
    end

    it "should have right actions" do
      action1 = Factory(:action, :service => @service)
      action2 = Factory(:action, :service => @service)
      @service.actions.should == [action1, action2]
    end

    it "should call helper when inner run" do
      rt = @service.inner_runtime :a => 1, :b => "2"
      rt.test_helper(1).should == "1"
      rt.a.should == 1
      rt.b.should == "2"
    end
  end

  describe "workflow" do
    before :each do
      @service = Service.new(@attr)
      @user = Factory(:user)

      $auth_url = 'http://test/auth/url'
      module AuthHelper
        extend self
        def test_auth(service, session, callback_url)
          "#{$auth_url}?callback=#{callback_url}"
        end

        def test_get_meta(service, session)
          { :pass => "foobar", :auth => service.auth_data[:auth] }
        end
      end
    end

    it "should get auth url" do
      @service.auth({}, "http://callback_url").should == "#{$auth_url}?callback=http://callback_url"
    end

    it "should get nil if no meta data" do
      @service.meta(@user).should == nil
    end

    it "should save meta data" do
      lambda do
        @service.auth_meta @user, {}
      end.should change(ServiceMetaWithUser, :count).by(1)
    end

    it "should get meta data" do
      @service.auth_meta @user, {}
      meta = @service.meta @user
      meta[:auth].should == @service.auth_data[:auth]
      meta[:pass].should == "foobar"
    end

    it "should replace meta data" do
      @service.auth_meta @user, {}
      @service.meta(@user)[:pass].should == "foobar"

      module AuthHelper
        extend self
        def test_get_meta(service, session)
          { :pass => "foo" }
        end
      end

      lambda do
        @service.auth_meta @user, {}
      end.should change(ServiceMetaWithUser, :count).by(0)
      @service.meta(@user)[:pass].should == "foo"
    end
  end
end
