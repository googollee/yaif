require 'spec_helper'

describe ServiceMetaWithUser do
  before :each do
    @user = FactoryGirl.create(:user)
    @service = FactoryGirl.create(:service)
    @attr = { :user => @user,
              :service => @service,
              :data => {} }
  end

  describe "create" do
    it "should success" do
      data = ServiceMetaWithUser.new(@attr)
      data.valid?.should be_true
    end

    describe "failed" do
      after :each do
        data = ServiceMetaWithUser.new(@attr)
        data.valid?.should be_false
      end

      it "should fail without user" do
        @attr[:user] = nil
      end

      it "should fail without service" do
        @attr[:service] = nil
      end
    end
  end
end
