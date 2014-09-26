require 'spec_helper'

describe Garoupa do

  let(:list) { [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l] }
  let(:no_options_groups) { Garoupa.make_groups(list) }

  describe ".make_groups" do
    it "returns a Groupa object" do
      expect(no_options_groups).to be_instance_of Garoupa
    end

    describe "group_sizes" do
      context "no target size given" do
        it "makes groups of four" do
          groups_sizes = no_options_groups.groups.map(&:size)
          expect(groups_sizes.all? { |s| s == 4 }).to be true
        end
      end

      context "target size given" do
        context "list size evenly divisible by target size" do
          it "makes groups of a specified size" do
            options = { target_size: 3 }
            groups = Garoupa.make_groups(list, options)
            groups_sizes = groups.groups.map(&:size)

            expect(groups_sizes.all? { |s| s == 3 }).to be true
          end
        end

        context "list size not evenly divisible by target size" do
          context "no max size difference specified" do
            it "has one group with a different size" do
              options = { target_size: 5 }
              groups = Garoupa.make_groups(list, options)
              groups_sizes = groups.groups.map(&:size)

              expect(groups_sizes).to match_array [5, 5, 2]
            end
          end

          context "max size difference specified" do
            context "max size difference not exceeded" do
              it "leaves the smaller group" do
                options = { target_size: 5, max_difference: 3 }
                groups = Garoupa.make_groups(list, options)
                groups_sizes = groups.groups.map(&:size)

                expect(groups_sizes).to match_array [5, 5, 2]
              end
            end
            context "max size difference exceeded" do
              it "disperses the smaller group" do
                options = { target_size: 5, max_difference: 2 }
                groups = Garoupa.make_groups(list, options)
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
          allow(list).to receive(:shuffle) do
            [:a, :l, :c, :k, :e, :j, :g, :h, :i, :f, :d, :b]
          end
          expected_groups = [[:a, :l, :c, :k], [:e, :j, :g, :h], [:i, :f, :d, :b]]

          expect(no_options_groups.groups).to match_array expected_groups
        end
      end

      context "past groups provided" do
        let(:past_groups) { [[:a, :b], [:a, :c], [:a, :d], [:a, :e], [:a, :f], [:a, :g], [:a, :h], [:a, :i]] }

        it "attempts to make groups with minimal repeats" do
          allow(list).to receive(:shuffle) do
            [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l]
          end

          options = { past_groups: past_groups }
          groups = Garoupa.make_groups(list, options).groups

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
end
