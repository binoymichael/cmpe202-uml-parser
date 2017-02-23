module Umlparser
  class ConstructorNode
    
    attr_reader :java_node
    attr_accessor :visible
    alias_method :visible?, :visible

    def initialize(java_node)
      @java_node = java_node
      @visible = true
    end

    def name
      @name ||= java_node.name.identifier
    end

    def parameters
      @parameters ||= Hash[java_node.parameters.map do |p|
                        [p.name.to_s, p.type.to_s]
                      end]
    end

    def type
      java_node.type.to_s
    end

    def modifier
      @modifier ||= begin
                      m = java_node.modifiers
                      m.any? ? m.first.name.downcase.to_sym : :package
                    end
    end

  end
end



