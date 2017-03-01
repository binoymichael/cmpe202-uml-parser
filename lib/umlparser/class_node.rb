module Umlparser
  class ClassNode
    
    attr_reader :java_node
    attr_reader :children, :dependencies
    def initialize(java_node)
      @java_node = java_node
      @children = {}
      @dependencies = []
    end

    def name
      @name ||= java_node.name.identifier
    end

    def modifier
      @modifier ||= begin
                      m = java_node.modifiers
                      m.any? ? m.first.name.downcase.to_sym : ''
                    end
    end

    def extends
      @extends = java_node.extended_types.map(&:to_s)
    end

    def implements
      @implements = java_node.implemented_types.map(&:to_s)
    end

  end
end
