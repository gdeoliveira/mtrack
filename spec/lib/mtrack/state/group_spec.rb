require "spec_helper"

describe MTrack::State::Group do
  context "newly instantiated" do
    it "is initialized empty" do
      expect(subject.tracked).to be_empty
    end
  end

  context "already in use" do
    let(:sample_tracked) { [:trk_1, :trk_2, :trk_3] }

    subject do
      described_class.new.tap do |o|
        o.merge_tracked sample_tracked
      end
    end

    it "is not empty" do
      expect(subject.tracked).to match_array(sample_tracked)
    end

    it "does not modify internal state through attribute readers" do
      expect(subject.tracked.add(:v)).to match_array(sample_tracked + [:v])
      expect(subject.tracked).to match_array(sample_tracked)
    end

    it "deletes tracked values" do
      expect(subject.delete_tracked(:trk_2)).to be(:trk_2)
      expect(subject.tracked).to match_array(sample_tracked - [:trk_2])
    end

    it "merges tracked values" do
      expect(subject.merge_tracked([:x, :y, :z])).to match_array([:x, :y, :z])
      expect(subject.tracked).to match_array(sample_tracked + [:x, :y, :z])
    end
  end
end
