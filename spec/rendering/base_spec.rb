require File.join(File.dirname(__FILE__), '/../spec_helper')

describe Gopher::Rendering::Base do
  before(:each) do
    @ctx = Gopher::Rendering::Base.new
  end

  it 'should add text' do
    @ctx.text("line 1")
    @ctx.text("line 2")
    @ctx.result.should == "line 1\nline 2\n"
  end

  it "should add breaks correctly" do
    @ctx.spacing 2
    @ctx.text("line 1")
    @ctx.text("line 2")
    @ctx.result.should == "line 1\n\nline 2\n\n"
  end

  it "br outputs a bunch of newlines" do
    @ctx.br(2).should == "\n\n"
  end

  it "uses to_s to output result" do
    @ctx.text("line 1")

    @ctx.to_s.should == @ctx.result
  end

  pending "block"

#  it "should make urls" do
#    @ctx.url("foo").should == "foo"
#  end
end
