require "spec_helper"

describe MTrack::ModuleMixin do
  describe "#track_methods" do
    context "no block given" do
      it "returns an empty set" do
        ret_val = ::Module.new.module_eval { track_methods :group }
        expect(ret_val).to be_a(Set)
        expect(ret_val).to be_empty
      end
    end
  end
end
