require "garoupa/version"
require "garoupa/dependencies"

class Garoupa

  DEFAULT_GROUP_SIZE = 4

  def self.make_groups(list, options = {})
    list_items_past_groupmates = past_groupmates(list, options[:past_groups])
    group_structure            = make_empty_group_structure(list.size, options[:target_size])
    corrected_group_structure  = correct_for_group_size_difference(group_structure, options[:max_difference])
    sorted_list                = sort(list, list_items_past_groupmates)
    groups                     = fill_group_structure(group_structure, sorted_list, list_items_past_groupmates)

    self.new(groups, list, list_items_past_groupmates)
  end

  def self.past_groupmates(list, past_groups)
    list.each_with_object( Hash.new ) do |list_item, previous_pairs|
      previous_pairs[list_item] = past_groupmates_for(list_item, past_groups)
    end
  end


  attr_reader :groups, :list, :past_groupmates

  def initialize(groups, list, past_groupmates)
    @groups          = groups
    @list            = list
    @past_groupmates = past_groupmates
  end

  def repeat_pairs
    list.each_with_object( Hash.new ) do |list_item, repeat_pairs|
      repeat_pairs[list_item] = group_for(list_item) & past_groupmates[list_item]
    end
  end

  def to_json
    { :groups          => groups,
      :list            => list,
      :past_groupmates => past_groupmates,
      :repeat_pairs    => repeat_pairs }.to_json
  end

  def to_s
    groups.map.with_index(1) { |group, index| "#{index}. " + group.join(", ") }.join("\n")
  end

  private
  def self.divide_list(list, group_size = nil)
    list.each_slice(group_size || DEFAULT_GROUP_SIZE).to_a
  end

  def self.correct_for_group_size_difference(groups, max_difference = nil)
    return groups unless max_difference

    if difference_in_group_sizes(groups) > max_difference
      groups = disperse_last_group(groups)
    end
    groups
  end

  def self.difference_in_group_sizes(groups)
    sizes = groups.map(&:size)
    sizes.max - sizes.min
  end

  def self.disperse_last_group(groups)
    last_group = groups.pop

    last_group.each_with_index do |element, index|
      groups[index] << element
    end

    groups
  end

  def self.make_empty_group_structure(list_size, target_size = nil)
    empty_list = Array.new(list_size) { nil }
    empty_groups = divide_list(empty_list, target_size)
  end

  def self.past_groupmates_for(element, past_groups = nil)
    return [] unless past_groups

    past_groups = past_groups.select { |group| group.include? element }
    past_groupmates = past_groups.flatten.uniq - [element]
  end

  def self.fill_group_structure(group_structure, list, previous_pairs = {})
    list.each do |list_item|
      place_in_best_group(list_item, group_structure, previous_pairs)
    end

    group_structure
  end

  def self.place_in_best_group(list_item, group_structure, previous_pairs)
    available_groups = group_structure.select { |group| group.include? nil }
    group_with_least_repeats = available_groups.min_by { |group| group & previous_pairs[list_item] }

    index_of_nil = group_with_least_repeats.index nil
    group_with_least_repeats[index_of_nil] = list_item

    return nil
  end

  def self.sort(list, past_groupmates = nil)
    return list.shuffle unless past_groupmates

    list.shuffle.sort do |item_a, item_b|
      item_a_number_of_past_groupmates = past_groupmates.fetch(item_a, []).size
      item_b_number_of_past_groupmates = past_groupmates.fetch(item_b, []).size

      item_b_number_of_past_groupmates <=> item_a_number_of_past_groupmates
    end
  end

  def group_for(list_item)
    groups.find { |group| group.include? list_item }
  end
end
