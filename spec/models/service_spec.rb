require 'spec_helper'

describe Service do
   before :each do
    @attr = { :name => "TestService",
              :icon => "file://./test.png",
              :description => "a test service",
              :auth_type => "none_auth",
              :auth_data => {},
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

    it "should inject helper" do
      @service.test_helper(1).should == "1"
      @service.respond_to?(:non_exist_helper).should be_false
      lambda do
        @service.non_exist_helper
      end.should raise_error
    end
  end
end
