require 'spec_helper'
require 'em_alldone'

describe EmAlldone do
  describe '.new' do
    it 'raises an error if no deferrables are passed as arguments' do
      lambda {
        EmAlldone.new
      }.should raise_error ArgumentError, /at least one/
    end

    it "raises an error if the argument isn't a deferrables" do
      lambda {
        EmAlldone.new 1, 2, 3
      }.should raise_error ArgumentError, /must be deferrables/
    end

    it 'accepts a callback' do
      EmAlldone.new(
        EM::DefaultDeferrable.new.tap {|d| d.succeed }
      ) { @it_ran = true }
      @it_ran.should be_true
    end
  end

  context "all the deferrables pass" do
    let(:d1) { EM::DefaultDeferrable.new.tap {|d| d.succeed } }
    let(:d2) { EM::DefaultDeferrable.new.tap {|d| d.succeed } }
    subject { EmAlldone.new(d1, d2) }
    it "runs the call back" do
      subject.callback { @it_ran = true }
      @it_ran.should be_true
    end
  end

  context "a deferrable doesn't finish" do
    let(:d1) { EM::DefaultDeferrable.new.tap {|d| d.succeed } }
    let(:d2) { EM::DefaultDeferrable.new }
    subject { EmAlldone.new(d1, d2) }
    it "does not run the call back" do
      subject.callback { @it_ran = true }
      @it_ran.should be_nil
    end
  end

  context "all the deferrables fail" do
    let(:d1) { EM::DefaultDeferrable.new.tap {|d| d.fail } }
    let(:d2) { EM::DefaultDeferrable.new.tap {|d| d.fail } }
    subject { EmAlldone.new(d1, d2) }
    it "runs the call back" do
      subject.callback { @it_ran = true }
      @it_ran.should be_true
    end
  end
end
