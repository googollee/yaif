require 'spec_helper'

describe MetaHelper do
  it "should eval in hash" do
    h = { :a => 1, :b => "b" }
    e = '"#{a}, #{b}"'
    hash_eval(h, e).should == "1, b"
  end
end
