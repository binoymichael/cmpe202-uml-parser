module Umlparser
  class AttributeNode
    
    attr_reader :java_node, :modifier
    attr_accessor :visible, :association, :reverse_association
    alias_method :visible?, :visible
    alias_method :association?, :association
    alias_method :reverse_association?, :reverse_association

    def initialize(modifier, java_node)
      @modifier = modifier
      @java_node = java_node
      @visible = true
      @reverse_association = nil

      @association = if java_node.type.element_type.is_a?(Java::ComGithubJavaparserAstType::ClassOrInterfaceType) 
                         collection? ? '0..*' : '0..1'
                     else
                       false
                     end
    end

    def name
      @name ||= java_node.name.identifier
    end

    def collection?
      case java_node.type
      when Java::ComGithubJavaparserAstType::ClassOrInterfaceType
        java_node.type.type_arguments.present?
      when Java::ComGithubJavaparserAstType::ArrayType
        true
      else
        false
      end
    end

    def formatted_type
      type + (collection? ? '[]' : '')
    end

    def type
      case java_node.type
      when Java::ComGithubJavaparserAstType::ClassOrInterfaceType
        if java_node.type.type_arguments.present?
          java_node.type.type_arguments.get.first.to_s
        else
          java_node.type.to_s
        end
      when Java::ComGithubJavaparserAstType::ArrayType
        java_node.type.element_type.to_s
      when Java::ComGithubJavaparserAstType::PrimitiveType
        java_node.type.to_s
      else
        java_node.type.to_s
      end
    end
  end
end

