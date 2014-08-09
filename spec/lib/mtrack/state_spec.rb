require "spec_helper"

describe MTrack::State do
  let(:sample_context) do
    { :con_1 => { :tracked => [:trk_1, :trk_2] },
      :con_2 => { :tracked => [:trk_2, :trk_3] }
    }
  end
  let(:sample_context_2) do
    { :con_2 => { :tracked => [:trk_3, :trk_4] },
      :con_3 => { :tracked => [:trk_4, :trk_5] }
    }
  end

  let(:sample_undefined) { [:und_1, :und_2, :und_3] }

  let(:sample_state) do
    described_class.new.tap do |o|
      sample_context.keys.each do |key|
        o[key].merge_tracked sample_context[key][:tracked]
      end
      sample_undefined.each {|v| o.add_undefined v }
    end
  end
  let(:sample_state_2) do
    described_class.new.tap do |o|
      sample_context_2.keys.each do |key|
        o[key].merge_tracked sample_context_2[key][:tracked]
      end
    end
  end

  it "adds a new context when using the `[]` operator" do
    expect(new_context = subject[:new_context]).to be_a(MTrack::State::Context)
    expect(subject[:new_context]).to be(new_context)
  end

  it "adds super states" do
    expect(subject.add_super_state(sample_state)).to be(sample_state)
    expect(subject.add_super_state(sample_state_2)).to be(sample_state_2)
  end

  context "newly instantiated" do
    context "without super state" do
      subject { described_class.new }

      it "does not have tracked methods" do
        expect(subject.tracked).to be_empty
      end
    end

    context "with super state" do
      subject { described_class.new sample_state }

      it "has super state's tracked methods" do
        expect(sample_state.tracked(:con_1)).to match_array(sample_context[:con_1][:tracked])
        expect(sample_state.tracked(:con_2)).to match_array(sample_context[:con_2][:tracked])
        expect(subject.tracked(:con_1)).to match_array(sample_state.tracked(:con_1))
        expect(subject.tracked(:con_2)).to match_array(sample_state.tracked(:con_2))
      end
    end

    context "with multiple super states" do
      subject { described_class.new(sample_state).tap {|s| s.add_super_state sample_state_2 } }

      it "merges tracked methods from all super states" do
        expect(subject.tracked(:con_1)).to match_array(sample_context[:con_1][:tracked])
        expect(subject.tracked(:con_2)).to match_array(sample_context[:con_2][:tracked] | sample_context_2[:con_2][:tracked])
        expect(subject.tracked(:con_3)).to match_array(sample_context_2[:con_3][:tracked])
      end

      it "returns tracked methods that are not undefined" do
        subject.add_undefined :trk_3
        expect(subject.tracked(:con_2)).to match_array((sample_context[:con_2][:tracked] | sample_context_2[:con_2][:tracked]) - [:trk_3])

        subject.delete_undefined :trk_3
        expect(subject.tracked(:con_2)).to match_array((sample_context[:con_2][:tracked] | sample_context_2[:con_2][:tracked]))
      end
    end
  end

  context "already in use" do
    subject { sample_state }

    it "is not empty" do
      expect(subject[:con_1].tracked).to match_array(sample_context[:con_1][:tracked])
      expect(subject[:con_2].tracked).to match_array(sample_context[:con_2][:tracked])
    end

    it "adds undefined methods" do
      expect(subject.add_undefined(:v)).to eq(:v)
    end

    it "deletes tracked methods" do
      expect(subject.delete_tracked(:trk_2)).to eq(:trk_2)
      expect(subject[:con_1].tracked).to match_array(sample_context[:con_1][:tracked] - [:trk_2])
      expect(subject[:con_2].tracked).to match_array(sample_context[:con_2][:tracked] - [:trk_2])
    end

    it "deletes undefined methods" do
      expect(subject.delete_undefined(:und_2)).to eq(:und_2)
    end

    it "returns tracked methods that are not undefined" do
      expect(subject.tracked(:con_1)).to match_array(sample_context[:con_1][:tracked])
      expect(subject.tracked(:con_2)).to match_array(sample_context[:con_2][:tracked])

      subject.add_undefined :trk_2
      expect(subject.tracked(:con_1)).to match_array(sample_context[:con_1][:tracked] - [:trk_2])
      expect(subject.tracked(:con_2)).to match_array(sample_context[:con_2][:tracked] - [:trk_2])

      subject.delete_undefined :trk_2
      expect(subject.tracked(:con_1)).to match_array(sample_context[:con_1][:tracked])
      expect(subject.tracked(:con_2)).to match_array(sample_context[:con_2][:tracked])
    end

    context "with super state" do
      subject { sample_state.tap {|s| s.add_super_state sample_state_2 } }

      it "merges tracked methods from current and super states" do
        expect(subject.tracked(:con_1)).to match_array(sample_context[:con_1][:tracked])
        expect(subject.tracked(:con_2)).to match_array(sample_context[:con_2][:tracked] | sample_context_2[:con_2][:tracked])
        expect(subject.tracked(:con_3)).to match_array(sample_context_2[:con_3][:tracked])
      end

      it "returns tracked methods that are not undefined" do
        subject.add_undefined :trk_3
        expect(subject.tracked(:con_2)).to match_array((sample_context[:con_2][:tracked] | sample_context_2[:con_2][:tracked]) - [:trk_3])

        subject.delete_undefined :trk_3
        expect(subject.tracked(:con_2)).to match_array((sample_context[:con_2][:tracked] | sample_context_2[:con_2][:tracked]))
      end
    end
  end
end
