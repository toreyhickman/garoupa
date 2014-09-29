require 'spec_helper'

describe Garoupa do

  let(:long_list) { [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l] }
  let(:garoupa_no_options) { Garoupa.make_groups(long_list) }

  let(:garoupa) { Garoupa.new(groups, list, past_groupmates) }
  let(:groups) { [[:a, :b], [:c, :d]] }
  let(:list) { [:a, :b, :c, :d] }
  let(:past_groupmates) do
    { :a => [:b, :c, :d],
      :b => [:a],
      :c => [],
      :d => [] }
  end


  describe ".make_groups" do
    it "returns a Groupa object" do
      expect(garoupa_no_options).to be_instance_of Garoupa
    end

    describe "group_sizes" do
      context "no target size given" do
        it "attemtps to make groups of the default group size" do

          expect(garoupa_no_options.groups.first.size).to eq Garoupa::DEFAULT_GROUP_SIZE
        end
      end

      context "target size given" do
        context "list size evenly divisible by target size" do
          it "makes groups of a specified size" do
            options = { target_size: 3 }
            groups = Garoupa.make_groups(long_list, options)
            groups_sizes = groups.groups.map(&:size)

            expect(groups_sizes.all? { |s| s == 3 }).to be true
          end
        end

        context "list size not evenly divisible by target size" do
          context "no max size difference specified" do
            it "has one group with a different size" do
              options = { target_size: 5 }
              groups = Garoupa.make_groups(long_list, options)
              groups_sizes = groups.groups.map(&:size)

              expect(groups_sizes).to match_array [5, 5, 2]
            end
          end

          context "max size difference specified" do
            context "max size difference not exceeded" do
              it "leaves the smaller group" do
                options = { target_size: 5, max_difference: 3 }
                groups = Garoupa.make_groups(long_list, options)
                groups_sizes = groups.groups.map(&:size)

                expect(groups_sizes).to match_array [5, 5, 2]
              end
            end
            context "max size difference exceeded" do
              it "disperses the smaller group" do
                options = { target_size: 5, max_difference: 2 }
                groups = Garoupa.make_groups(long_list, options)
                groups_sizes = groups.groups.map(&:size)

                expect(groups_sizes).to match_array [6, 6]
              end
            end
          end
        end
      end
    end

    describe "group make up" do
      context "no past groups provided" do
        it "divides shuffled list into groups" do
          allow(long_list).to receive(:shuffle) do
            [:a, :l, :c, :k, :e, :j, :g, :h, :i, :f, :d, :b]
          end
          expected_groups = [[:a, :l, :c, :k], [:e, :j, :g, :h], [:i, :f, :d, :b]]

          expect(garoupa_no_options.groups).to match_array expected_groups
        end
      end

      context "past groups provided" do
        let(:past_groups) { [[:a, :b], [:a, :c], [:a, :d], [:a, :e], [:a, :f], [:a, :g], [:a, :h], [:a, :i]] }

        it "attempts to make groups with minimal repeats" do
          allow(long_list).to receive(:shuffle) do
            [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l]
          end

          options = { past_groups: past_groups }
          groups = Garoupa.make_groups(long_list, options).groups

          a_group = groups.find { |group| group.include? :a }
          expect(a_group).to match_array [:a, :j, :k, :l]
        end
      end
    end
  end

  describe ".past_groupmates" do
    let(:list) { [:a, :b, :c, :d] }
    let(:past_groups) { [[:a, :b], [:a, :c]] }

    it "maps list items to their previous groupmates" do
      past_group_map = Garoupa.past_groupmates(list, past_groups)

      expect(past_group_map[:a]).to match_array [:b, :c]
      expect(past_group_map[:b]).to match_array [:a]
      expect(past_group_map[:c]).to match_array [:a]
      expect(past_group_map[:d]).to be_empty
    end
  end

  describe "accessor methods" do
    let(:groups) { :groups_argument }
    let(:list) { :list_argument }
    let(:past_groupmates) { :past_groupmates_argument }

    let(:garoupa) { Garoupa.new(groups, list, past_groupmates) }

    it "returns the list" do
      expect(garoupa.list).to eq list
    end

    it "returns the groups" do
      expect(garoupa.groups).to eq groups
    end

    it "returns the past groupmates" do
      expect(garoupa.past_groupmates).to eq past_groupmates
    end
  end

  describe "#repeat_pairs" do
    it "returns the repeat pairs for each list item" do
      expected_repeat_pairs = { :a => [:b],
                                :b => [:a],
                                :c => [],
                                :d => [] }

      expect(garoupa.repeat_pairs).to eq expected_repeat_pairs
    end
  end

  describe "#to_json" do
    it "returns a JSON formatted string" do
      expect { JSON.parse(garoupa.to_json) }.to_not raise_error
    end

    it "includes groups, list, past groupmates, and repeat pairs" do
      expected_json = { :groups          => garoupa.groups,
                        :list            => garoupa.list,
                        :past_groupmates => garoupa.past_groupmates,
                        :repeat_pairs    => garoupa.repeat_pairs }.to_json

      expect(garoupa.to_json).to eq expected_json
    end
  end

  describe "#to_s" do
    it "returns a numbered list of the groups" do
      expected_string = "1. a, b\n2. c, d"

      expect(garoupa.to_s).to eq expected_string
    end
  end
end
