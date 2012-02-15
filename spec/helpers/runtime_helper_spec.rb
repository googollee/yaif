require 'spec_helper'

describe RuntimeHelper do
  describe "class InnerRuntime" do
    it "should get inner runtime with params as func" do
      rt = RuntimeHelper::InnerRuntime.new
      rt.add_params :a => 1, :b => "2"
      rt.a.should == 1
      rt.b.should == "2"
      lambda do
        rt.c
      end.should raise_error
      rt.add_params :c => "3"
      rt.a.should == 1
      rt.b.should == "2"
      rt.c.should == "3"
    end

    it "should have urlencode method" do
      rt = RuntimeHelper::InnerRuntime.new
      str = "fdaf' erw"
      rt.urlencode(str).should == CGI::escape(str)
    end

    it "should have htmlunescape method" do
      rt = RuntimeHelper::InnerRuntime.new
      str = "L&#xE4;tt B bed. Tv&#xE5; omg&#xE5;ngar A:0 och A:0"
      rt.xmlunescape(str).should == CGI::unescape_html(str)
    end

    it "should have json method to parse json" do
      rt = RuntimeHelper::InnerRuntime.new
      a = { "a" => "1", "b" => 2}
      rt.json(a.to_json).should == a
    end

    it "should parse json" do
      content = [{"a" => "1"}, {"a" => "2"}].to_json
      rt = RuntimeHelper::InnerRuntime.new
      ret = rt.parse_json content do |i|
        { :a => i["a"] }
      end
      ret.should == [{:a => "1"}, {:a => "2"}]
    end

    it "should have xml method to get DOM" do
      rt = RuntimeHelper::InnerRuntime.new
      doc = rt.xml('<abc>a</abc>')
      (doc/'abc').inner_text.should == "a"
    end

    it "should parse xml" do
      content = <<EOF
      <feed>
        <item>
          <title>item1</title>
        </item>
        <item>
          <title>item2</title>
        </item>
        <item>
          <title>item3</title>
        </item>
      </fedd>
EOF
      rt = RuntimeHelper::InnerRuntime.new
      ret = rt.parse_xml content, "feed > item" do |i|
        { :title => (i / 'title').inner_text }
      end
      ret.should == [{:title => "item1"}, {:title => "item2"}, {:title => "item3"}]
    end

    it "should grab text" do
      rt = RuntimeHelper::InnerRuntime.new
      str = "<abc>tag: content</abc>"
      rt.grab_text(str, /<abc>tag: (.*?)</m).should == "content"
      rt.grab_text(str, /<123>tag: (.*?)</m).should == ""
    end

    it "should generate multipart post body" do
      rt = RuntimeHelper::InnerRuntime.new
      params = { :status => "abc", :pic => '123' }
      post = rt.multipart params
      post.should == Net::HTTP::Post::Multipart.new('/', params).body_stream.read
    end
  end
end
