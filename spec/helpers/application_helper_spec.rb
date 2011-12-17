require 'spec_helper'

describe "JSONCoder" do
  before :each do
    @coder = JSONCoder.new
    @data = [1, 2, 3]
  end

  it "should dump to json" do
    @coder.dump(@data).class.should == "String".class
  end

  it "should reload to same object" do
    @coder.load(@coder.dump(@data)).should == @data
  end
end

describe "SymbolHashJSONCoder" do
  before :each do
    @coder = SymbolHashJSONCoder.new
    @data = { :a => 1, :b => 2, :c => { "a" => "1" } }
  end

  it "should dump to json" do
    @coder.dump(@data).class.should == "String".class
  end

  it "should reload to same object" do
    @coder.load(@coder.dump(@data)).should == @data
  end
end

describe "SymbolArrayJSONCoder" do
  before :each do
    @coder = SymbolArrayJSONCoder.new
    @data = [:a, :b, :c]
  end

  it "should dump to json" do
    @coder.dump(@data).class.should == "String".class
  end

  it "should reload to same object" do
    @coder.load(@coder.dump(@data)).should == @data
  end
end
