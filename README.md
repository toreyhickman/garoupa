# Garoupa

Garoupa was written to facilitate the assignment of groups at Dev Bootcamp where students are assigned to weekly groups.  It should be generalizable to other contexts, taking an item list and returning a new Garoupa object with the assigned groups.  Options allow for specifying a target group size, a maximum difference in group sizes if the number of list items is not evenly divisible by the target group size, and providing past groups so that list items can be grouped with new groupmates.

[Garoupa is apparently a Portugese name, from which the name of the grouper fish is believed to be derived](http://en.wikipedia.org/wiki/Grouper#Name_origin).  The things you learn when the desired name for your  gem is taken ...

## Installation

Add this line to your application's Gemfile:

    gem 'garoupa'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install garoupa

## Usage

The Garoupa library consists of one class:  `Garoupa`.  The class has two publicly defined class methods:

- `.make_groups`
- `.past_groupmates`

### `.make_groups`

```ruby
groups = Garoupa.make_groups [:a, :b, :c, :d, :e, :f, :g, :h]

=> #<Garoupa:0x007fb523552938 
     @groups=[[:a, :h, :b, :g], [:f, :d, :c, :e]], 
     @list=[:a, :b, :c, :d, :e, :f, :g, :h], 
     @past_groupmates={:a=>[], :b=>[], :c=>[], 
                       :d=>[], :e=>[], :f=>[], 
                       :g=>[], :h=>[]}
   >
```
*Figure 1*.  Making groups from a list.

`.make_groups` takes a list of arguments (i.e., an array) and returns the groups within an instance of the `Garoupa` class (see Figure 1).

The `.make_groups` methods also accepts an options hash where you can specify 

- target group size
- a max difference in group sizes
- past groups

#### :target_size

```ruby
list = [:a, :b, :c, :d, :e, :f, :g, :h]

groups = Garoupa.make_groups list, { target_size: 3 }
  => #<Garoupa:0x007fb523572f80 
       @groups=[[:c, :d, :h], [:f, :a, :e], [:b, :g]], 
       @list=[:a, :b, :c, :d, :e, :f, :g, :h], 
       @past_groupmates={:a=>[], ... }>
```
*Figure 2*.  Making groups with a target size.

The `Garoupa` class has a constant, `DEFAULT_GROUP_SIZE`, that is used to determine the size of each group.  This can be overwritten by providing a target size when calling `.make_groups` (see Figure 2).  As many groups as possible will be make with the target group size.  If the number of list items is not evenly divisible by the target size, the last group will have less members than the target size.  This is evident in Figure 2 where the eight list items were divided into two groups of three, the target size, and one group of two.

#### :max_difference

```ruby
list = [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j]

groups = Garoupa.make_groups list, { target_size: 3, max_difference: 1 }
  => #<Garoupa:0x007fb5235900a8 
       @groups=[[:d, :g, :c, :b], [:f, :a, :e], [:i, :j, :h]], 
       @list=[:a, :b, :c, :d, :e, :f, :g, :h, :i, :j], 
       @past_groupmates={:a=>[], ... }>
```

*Figure 3*.  Making groups with a target size and maximum difference in group size.

If the groups will not be even, a maximum difference in group size can be specified.  In Figure 3, the target size is three, but with ten items in the list, the groups will include three groups of three and one group of one.  By specifying a maximum difference of one, the last groups will be dispersed into the three groups of three, resulting in one group of four and two groups of three.

#### :past_groups

```ruby
list = [:a, :b, :c, :d]
past_groups = [[:a, :b],[:a, :c]]

groups = Garoupa.make_groups list, { target_size: 2, past_groups: past_groups }
  => #<Garoupa:0x007f86c4273088 
       @groups=[[:a, :d], [:b, :c]], 
       @list=[:a, :b, :c, :d], 
       @past_groupmates={:a=>[:b, :c], :b=>[:a], :c=>[:a], :d=>[]}>
```

*Figure 4*.  Making groups based on past groups.

When we pass in the optional past groups, `.make_groups` will try to place items in groups with new groupmates.  In the `past_groups` defined in Figure 4, Item `:a` has already been grouped with Items `:b` and `:c`.  Item `:a` has not been grouped with Item `:d`; therefore, the ideal groups would be Items `:a` and `:d` together and Items `:b` and `:c` together.  In these groups, no item would have a repear groupmate.

`Garoupa` attempts to make groups with no repeat pairs by calculating the past groupmates for each list item and then placing the items with the most past groupmates into groups first.  Essentially, trying to place items with more constraints before items with less constraints.

Certainly, calculating all possible groupings and selecting one without any repeat pairs is possible, but it becomes impractical with larger group sizes or when repeat groupmates are inevitable.

### `.past_groupmates`

```ruby
list = [:a, :b, :c, :d]
past_groups = [[:a, :b],[:a, :c]]

Garoupa.past_groupmates list, past_groups
  => {:a=>[:b, :c], :b=>[:a], :c=>[:a], :d=>[]} 
```

*Figure 5*.  Finding the past groupmates for list items.

The second class method, `.past_groupmates`, takes a list and past groups and returns a map of the list items and their past_groupmates, as seen in Figure 5.

### `Garoupa` instances

Instances of the `Garoupa` class are instantiated with groups, a list of items, and past groupmates.  New instances are returned from `Garoupa.make_groups`, but they can also be made by providing all three required arguments.  Each argument is saved as an instance variable and retrievable through getter methods.

Additionally, there are three public instance methods:

- `#repeat_pairs`
- `#to_json`
- `#to_s`

#### `#repeat_pairs`

```ruby
list = [:a, :b, :c, :d]
past_groups = [[:a, :b],[:a, :c], [:a, :d]]

groups = Garoupa.make_groups list, target_size: 2, past_groups: past_groups
  => #<Garoupa:0x007f86c414e4a0 
       @groups=[[:a, :d], [:c, :b]], 
       @list=[:a, :b, :c, :d], 
       @past_groupmates={:a=>[:b, :c, :d], :b=>[:a], :c=>[:a], :d=>[:a]}> 

groups.repeat_pairs
  => {:a=>[:d], :b=>[], :c=>[], :d=>[:a]}
```

*Figure 6*.  Repeat pairs reported for a groups.

An instance of the `Garoupa` class is able to report which list items are in groups with repeat pairs.  `#repeat_pairs` returns a hash with each list item mapped to the repeat pairs in its group (see Figure 6).

#### `#to_json`

The `#to_json` method returns a JSON formatted string representing the `Garoupa` instance.  It includes, the groups, list, past groupmates, and repeat pairs.

#### `#to_s`

```ruby
list = [:a, :b, :c, :d]
past_groups = [[:a, :b],[:a, :c]]

groups = Garoupa.make_groups list, target_size: 2, past_groups: past_groups
  => #<Garoupa:0x007f86c414e4a0 
       @groups=[[:a, :d], [:b, :c]], 
       @list=[:a, :b, :c, :d], 
       @past_groupmates={:a=>[:b, :c], :b=>[:a], :c=>[:a], :d=>[]}> 

puts groups
1. a, d
2. b, c
  => nil
```

*Figure 7*.  A `Garoupa` is printed as a numbered list.


The `#to_s` methods returns a numbered list of the groups (see Figure 7).


## Contributing

If you'd like to help improve Garoupa by adding a new feature, please fork the repository and submit a pull request for your feature branch.  Also, please report any bugs that you find.
