require 'spec_helper'

describe RuntimeHelper do
  describe "class InnerRuntime" do
    it "should get inner runtime with helper" do
      inner_runtime = InnerRuntime.new "def test_helper(a)
                                          a.to_s
                                        end", {}
      inner_runtime.test_helper(1).should == "1"
      inner_runtime.respond_to?(:non_exist_helper).should be_false
      lambda do
        inner_runtime.non_exist_helper
      end.should raise_error
    end

    it "should get inner runtime with params as func" do
      inner_runtime = InnerRuntime.new "", :a => 1, :b => "2"
      inner_runtime.a.should == 1
      inner_runtime.b.should == "2"
    end
  end
end
