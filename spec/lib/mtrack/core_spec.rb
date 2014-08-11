require "spec_helper"

METHOD_DEFINITION = proc {}

describe MTrack::Core do
  let(:base_module_1) do
    Module.new.tap do |m|
      m.module_eval do
        define_method :unt_1, METHOD_DEFINITION
        track_methods { define_method :meth, METHOD_DEFINITION }
        track_methods :numbers do
          track_methods(:odd) { define_method :one, METHOD_DEFINITION }
          track_methods(:even) { define_method :two, METHOD_DEFINITION }
        end
        define_method :unt_2, METHOD_DEFINITION
      end
    end
  end

  let(:base_module_2) do
    Module.new.tap do |m|
      m.module_eval do
        define_method :unt_2, METHOD_DEFINITION
        track_methods { define_method :meth, METHOD_DEFINITION }
        track_methods :numbers do
          track_methods(:even) { define_method :two, METHOD_DEFINITION }
          track_methods(:odd) { define_method :three, METHOD_DEFINITION }
        end
        define_method :unt_3, METHOD_DEFINITION
      end
    end
  end

  let(:base_module_3) do
    Module.new.tap do |m|
      m.module_eval do
        define_method :unt_3, METHOD_DEFINITION
        track_methods { define_method :meth, METHOD_DEFINITION }
        track_methods :numbers do
          track_methods(:odd) { define_method :three, METHOD_DEFINITION }
          track_methods(:even) { define_method :four, METHOD_DEFINITION }
        end
        define_method :unt_4, METHOD_DEFINITION
      end
    end
  end

  let(:sub_module_1) do
    bm_1 = base_module_1
    bm_2 = base_module_2
    Module.new.tap do |m|
      m.module_eval do
        include bm_1
        define_method :unt_4, METHOD_DEFINITION
        track_methods { define_method :meth, METHOD_DEFINITION }
        track_methods :numbers do
          track_methods(:even) { define_method :four, METHOD_DEFINITION }
          track_methods(:odd) { define_method :five, METHOD_DEFINITION }
        end
        define_method :unt_5, METHOD_DEFINITION
        include bm_2
      end
    end
  end

  let(:sub_module_2) do
    bm_3 = base_module_3
    Module.new.tap do |m|
      m.module_eval do
        define_method :unt_5, METHOD_DEFINITION
        track_methods { define_method :meth, METHOD_DEFINITION }
        include bm_3
        track_methods :numbers do
          track_methods(:odd) { define_method :five, METHOD_DEFINITION }
          track_methods(:even) { define_method :six, METHOD_DEFINITION }
        end
        define_method :unt_6, METHOD_DEFINITION
      end
    end
  end

  let(:super_class) do
    sm_1 = sub_module_1
    Class.new.tap do |c|
      c.class_eval do
        include sm_1
        define_method :unt_6, METHOD_DEFINITION
        track_methods { define_method :meth, METHOD_DEFINITION }
        track_methods :numbers do
          track_methods(:even) { define_method :six, METHOD_DEFINITION }
          track_methods(:odd) { define_method :seven, METHOD_DEFINITION }
        end
        define_method :unt_7, METHOD_DEFINITION
      end
    end
  end

  let(:sub_class) do
    sm_2 = sub_module_2
    sc = super_class
    Class.new(sc).tap do |c|
      c.class_eval do
        define_method :unt_7, METHOD_DEFINITION
        track_methods { define_method :meth, METHOD_DEFINITION }
        track_methods :numbers do
          track_methods(:odd) { define_method :seven, METHOD_DEFINITION }
          track_methods(:even) { define_method :eight, METHOD_DEFINITION }
        end
        define_method :unt_8, METHOD_DEFINITION
        include sm_2
      end
    end
  end

  context "base module 1" do
    subject { base_module_1 }

    it "tracks methods" do
      expect(subject.tracked_methods).to match_array([:meth])
      expect(subject.tracked_methods(:numbers)).to match_array([:one, :two])
      expect(subject.tracked_methods(:odd)).to match_array([:one])
      expect(subject.tracked_methods(:even)).to match_array([:two])
    end

    it "untracks removed methods" do
      subject.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to be_empty
    end

    it "untracks undefined methods" do
      subject.module_eval { undef_method :meth }
      expect(subject.tracked_methods).to be_empty

      subject.module_eval { define_method :meth, METHOD_DEFINITION }
      expect(subject.tracked_methods).to be_empty
    end
  end

  context "base module 2" do
    subject { base_module_2 }

    it "tracks methods" do
      expect(subject.tracked_methods).to match_array([:meth])
      expect(subject.tracked_methods(:numbers)).to match_array([:two, :three])
      expect(subject.tracked_methods(:even)).to match_array([:two])
      expect(subject.tracked_methods(:odd)).to match_array([:three])
    end

    it "untracks removed methods" do
      subject.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to be_empty
    end

    it "untracks undefined methods" do
      subject.module_eval { undef_method :meth }
      expect(subject.tracked_methods).to be_empty

      subject.module_eval { define_method :meth, METHOD_DEFINITION }
      expect(subject.tracked_methods).to be_empty
    end
  end

  context "base module 3" do
    subject { base_module_3 }

    it "tracks methods" do
      expect(subject.tracked_methods).to match_array([:meth])
      expect(subject.tracked_methods(:numbers)).to match_array([:three, :four])
      expect(subject.tracked_methods(:odd)).to match_array([:three])
      expect(subject.tracked_methods(:even)).to match_array([:four])
    end

    it "untracks removed methods" do
      subject.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to be_empty
    end

    it "untracks undefined methods" do
      subject.module_eval { undef_method :meth }
      expect(subject.tracked_methods).to be_empty

      subject.module_eval { define_method :meth, METHOD_DEFINITION }
      expect(subject.tracked_methods).to be_empty
    end
  end

  context "sub module 1" do
    subject { sub_module_1 }

    it "tracks methods" do
      expect(subject.tracked_methods).to match_array([:meth])
      expect(subject.tracked_methods(:numbers)).to match_array([:one, :two, :three, :four, :five])
      expect(subject.tracked_methods(:odd)).to match_array([:one, :three, :five])
      expect(subject.tracked_methods(:even)).to match_array([:two, :four])
    end

    it "untracks removed methods" do
      subject.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      base_module_1.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      base_module_2.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to be_empty
    end

    it "untracks undefined methods" do
      subject.module_eval { undef_method :meth }
      expect(subject.tracked_methods).to be_empty

      subject.module_eval { define_method :meth, METHOD_DEFINITION }
      expect(subject.tracked_methods).to match_array([:meth])
    end
  end

  context "sub module 2" do
    subject { sub_module_2 }

    it "tracks methods" do
      expect(subject.tracked_methods).to match_array([:meth])
      expect(subject.tracked_methods(:numbers)).to match_array([:three, :four, :five, :six])
      expect(subject.tracked_methods(:odd)).to match_array([:three, :five])
      expect(subject.tracked_methods(:even)).to match_array([:four, :six])
    end

    it "untracks removed methods" do
      base_module_3.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      subject.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to be_empty
    end

    it "untracks undefined methods" do
      subject.module_eval { undef_method :meth }
      expect(subject.tracked_methods).to be_empty

      subject.module_eval { define_method :meth, METHOD_DEFINITION }
      expect(subject.tracked_methods).to match_array([:meth])
    end
  end

  context "super class" do
    subject { super_class }

    it "tracks methods" do
      expect(subject.tracked_methods).to match_array([:meth])
      expect(subject.tracked_methods(:numbers)).to match_array([:one, :two, :three, :four, :five, :six, :seven])
      expect(subject.tracked_methods(:odd)).to match_array([:one, :three, :five, :seven])
      expect(subject.tracked_methods(:even)).to match_array([:two, :four, :six])
    end

    it "untracks removed methods" do
      subject.class_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      sub_module_1.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      base_module_2.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      base_module_1.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to be_empty
    end

    it "untracks undefined methods" do
      subject.module_eval { undef_method :meth }
      expect(subject.tracked_methods).to be_empty

      subject.module_eval { define_method :meth, METHOD_DEFINITION }
      expect(subject.tracked_methods).to match_array([:meth])
    end
  end

  context "sub class" do
    subject { sub_class }

    it "tracks methods" do
      expect(subject.tracked_methods).to match_array([:meth])
      expect(subject.tracked_methods(:numbers)).to match_array([:one, :two, :three, :four, :five, :six, :seven, :eight])
      expect(subject.tracked_methods(:odd)).to match_array([:one, :three, :five, :seven])
      expect(subject.tracked_methods(:even)).to match_array([:two, :four, :six, :eight])
    end

    it "untracks removed methods" do
      base_module_1.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      base_module_2.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      base_module_3.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      sub_module_1.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      sub_module_2.module_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      super_class.class_eval { remove_method :meth }
      expect(subject.tracked_methods).to match_array([:meth])

      subject.class_eval { remove_method :meth }
      expect(subject.tracked_methods).to be_empty
    end

    it "untracks undefined methods" do
      subject.module_eval { undef_method :meth }
      expect(subject.tracked_methods).to be_empty

      subject.module_eval { define_method :meth, METHOD_DEFINITION }
      expect(subject.tracked_methods).to match_array([:meth])
    end
  end

  context "partially defined" do
    context "module" do
      it "tracks methods" do
        M = Module.new

        expect do
          M.module_eval do
            track_methods do
              define_method :meth_1, METHOD_DEFINITION
              define_method :meth_2, METHOD_DEFINITION
              raise "Unexpected error"
              define_method :meth_3, METHOD_DEFINITION
              define_method :meth_4, METHOD_DEFINITION
            end
          end
        end.to raise_error(RuntimeError, "Unexpected error")

        expect(M.public_instance_methods(false)).to match_array([:meth_1, :meth_2])
        expect(M.tracked_methods).to match_array([:meth_1, :meth_2])
      end
    end

    context "class" do
      it "tracks methods" do
        C = Class.new

        expect do
          C.class_eval do
            track_methods do
              define_method :meth_1, METHOD_DEFINITION
              define_method :meth_2, METHOD_DEFINITION
              raise "Unexpected error"
              define_method :meth_3, METHOD_DEFINITION
              define_method :meth_4, METHOD_DEFINITION
            end
          end
        end.to raise_error(RuntimeError, "Unexpected error")

        expect(C.public_instance_methods(false)).to match([:meth_1, :meth_2])
        expect(C.tracked_methods).to match_array([:meth_1, :meth_2])
      end
    end
  end
end
