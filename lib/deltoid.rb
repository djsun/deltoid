require 'rubygems'
require 'bundler/setup'
require 'set'
require 'nokogiri'

class Deltoid
  def initialize(strings)
    @strings = strings
    @parsed = @strings.map { |s| self.class.parse(s) }
  end

  # Find the differences between the documents.
  def delta
    deltas = self.class.delta_documents(@parsed)
    self.class.friendly_deltas(deltas, @parsed)
  end

  def self.friendly_deltas(deltas, root_nodes)
    deltas.map do |delta|
      root = delta.ancestors.last
      {
        :index   => root_nodes.find_index(root),
        :content => delta.content,
        :xpath   => delta.path,
      }
    end
  end

  # Returns an array of nodes that are different between +documents+.
  def self.delta_documents(documents)
    roots = documents.map { |document| document.root }
    delta_nodes(roots)
  end

  # Returns an array of nodes that are different between +nodes+.
  #
  # Idea: could this be rewritten as a special case of delta_nodes_group?
  def self.delta_nodes(nodes)
    deltas = []
    deltas.concat(nodes) unless match?(nodes)
    deltas.concat(delta_children_nodes(nodes))
  end

  # Returns an array of nodes that are different between +nodes+.
  def self.delta_children_nodes(nodes)
    children = nodes.map { |node| node.children.select { |k| k.element? } }
    delta_nodes_group(children)
  end

  def self.delta_nodes_group(nodes_group)
    matches_group = find_matches_group(nodes_group)
    deltas = find_deltas(nodes_group, matches_group)
    matches_group.each do |matches|
      deltas.concat(delta_children_nodes(matches))
    end
    deltas
  end

  # Parameters:
  #   +all_nodes_group+ is an array of an array of nodes, with the same
  #   length as the number of documents being diffed.
  # Returns:
  #   an array of array of nodes that match each other
  def self.find_matches_group(all_nodes_group)
    first_nodes = all_nodes_group.first
    remaining_nodes_group = all_nodes_group.drop(1)
    matches_group = []
    first_nodes.each do |node|
      matches = find_matches_in(node, remaining_nodes_group)
      matches_group << matches unless matches.empty?
    end
    matches_group
  end

  # If +node+ can be found in each of +remaining_nodes_group+, return an
  # array of each matching node. Otherwise, return [].
  #
  # Parameters:
  #   +nodes_group+ is an array of an array of nodes, with the same length
  #   as the number of documents being diffed.
  # Returns:
  #   An array containing each matched node; otherwise [].
  def self.find_matches_in(node, remaining_nodes_group)
    matches = [node]
    remaining_nodes_group.each do |nodes_group|
      match = find_match(node, nodes_group)
      if match
        matches << match
      else
        matches = []
        break
      end
    end
    matches
  end

  # If +the_node+ matches a node in +node_group+, return the latter node.
  # Otherwise, return nil.
  #
  # Note: stops after finding the first match.
  def self.find_match(the_node, nodes)
    nodes.each do |node|
      return node if match?([the_node, node])
    end
    nil
  end

  # Figure out the deltas (differences) based on:
  #   +nodes_group+ (an array of array of nodes)
  #   +matches_group+ (an array of array of nodes)
  def self.find_deltas(nodes_group, matches_group)
    nodes_group.flatten - matches_group.flatten
  end

  # Do the +nodes+ match?
  def self.match?(nodes)
    names = nodes.map { |node| node.name }.uniq
    names.length == 1 && attributes_match?(nodes) && content_match?(nodes)
  end

  # Do the attributes of the +nodes+ match?
  def self.attributes_match?(nodes)
    attributes = nodes.map { |node| attributes(node) }.uniq
    attributes.length == 1
  end

  # Does the content of the +nodes+ match? (Note: only applies to nodes whose
  # children are all text nodes.)
  def self.content_match?(nodes)
    return true if nodes.any? { |node| !all_children_are_text?(node) }
    content = nodes.map { |node| node.content }.uniq
    content.length == 1
  end

  def self.attributes(node)
    map = {}
    node.attributes.values.each do |attribute|
      name, value = attribute.name, attribute.value
      map[name] = value
    end
    map
  end

  # (Internal API)
  def self.all_children_are_text?(node)
    node.children.all? { |x| x.text? }
  end

  # (Internal API)
  def self.parse(item)
    Nokogiri::HTML::Document.parse(item)
  end

end
