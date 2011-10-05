require 'spec_helper'

describe User do
  before(:each) do
    @attr = { :name => "example",
              :email => "emaple@domain.com",
              :password => "foobar",
              :password_confirmation => "foobar",
    }
  end

  it "should be valid with right attr" do
    user = User.new(@attr)
    user.valid?.should be_true
  end

  describe "when attr has wrong value" do
    before(:each) do
      @user = User.new(@attr)
    end

    it "should fail with empty name or too long name" do
      @user.name = ""
      @user.valid?.should be_false

      @user.name = '1' * 100
      @user.valid?.should be_false
    end

    it "should fail with not valid mail" do
      @user.email = ""
      @user.valid?.should be_false

      @user.email = "123"
      @user.valid?.should be_false
    end

    it "should fail with empty password or too long password" do
      @user.password = @user.password_confirmation = ""
      @user.valid?.should be_false

      @user.password = @user.password_confirmation = '1' * 100
      @user.valid?.should be_false
    end

    it "should fail when password not confirmed" do
      @user.password = "foobar"
      @user.password_confirmation = "barfoo"
      @user.valid?.should be_false
    end
  end
end
