require "spec_helper"

describe MTrack::State::Context do
  context "newly instantiated" do
    it "is initialized empty" do
      expect(subject.tracked).to be_empty
      expect(subject.undefined).to be_empty
    end
  end

  context "already in use" do
    let(:default_tracked) { [:trk_1, :trk_2, :trk_3] }
    let(:default_undefined) { [:und_1, :und_2, :und_3] }

    subject do
      described_class.new.tap do |o|
        o.merge_tracked default_tracked
        default_undefined.each {|v| o.add_undefined v }
      end
    end

    it "is not empty" do
      expect(subject.tracked).to match_array(default_tracked)
      expect(subject.undefined).to match_array(default_undefined)
    end

    it "does not modify internal state through attribute readers" do
      expect(subject.tracked.add(:v)).to match_array(default_tracked + [:v])
      expect(subject.undefined.add(:v)).to match_array(default_undefined + [:v])
      expect(subject.tracked).to match_array(default_tracked)
      expect(subject.undefined).to match_array(default_undefined)
    end

    it "adds undefined values" do
      expect(subject.add_undefined(:v)).to be(:v)
      expect(subject.undefined).to match_array(default_undefined + [:v])
    end

    it "deletes tracked values" do
      expect(subject.delete_tracked(:trk_2)).to be(:trk_2)
      expect(subject.tracked).to match_array(default_tracked - [:trk_2])
    end

    it "deletes undefined values" do
      expect(subject.delete_undefined(:und_2)).to be(:und_2)
      expect(subject.undefined).to match_array(default_undefined - [:und_2])
    end

    it "merges tracked values" do
      expect(subject.merge_tracked([:x, :y, :z])).to match_array([:x, :y, :z])
      expect(subject.tracked).to match_array(default_tracked + [:x, :y, :z])
    end
  end
end
