require 'spec_helper'

describe Service do
  describe "create" do
    before(:each) do
      @attr = { :name => "WeatherCN",
                :description => "Get the weather report.",
                :auth_uri => "http://www.weather.com.cn",
                :auth_type => "none_auth",
                :auth_data => {}}
    end

    it "should success with right attr" do
      service = Service.new(@attr)
      service.valid?.should be_true
    end

    it "should fail with empty or too long name" do
      @attr[:name] = ""
      service = Service.new(@attr)
      service.valid?.should be_false
    end

    it "should fail with empty auth_uri" do
      @attr[:auth_uri] = ""
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
end
