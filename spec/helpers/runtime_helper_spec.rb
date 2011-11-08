require 'spec_helper'

describe RuntimeHelper do
  describe "class InnerRuntime" do
    it "should get inner runtime with params as func" do
      inner_runtime = InnerRuntime.new :a => 1, :b => "2"
      inner_runtime.a.should == 1
      inner_runtime.b.should == "2"
    end

    it "should have xml method to get DOM" do
      rt = InnerRuntime.new nil
      doc = rt.xml('<abc>a</abc>')
      (doc/'abc').inner_text.should == "a"
    end
  end
end
