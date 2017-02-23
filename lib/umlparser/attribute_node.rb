module Umlparser
  class AttributeNode
    
    attr_reader :java_node
    attr_accessor :visible
    alias_method :visible?, :visible

    def initialize(modifier, java_node)
      @modifier = modifier
      @java_node = java_node
      @visible = true
    end

    def name
      @name ||= java_node.name.identifier
    end

    def association?
      java_node.type.element_type === Java::ComGithubJavaparserAstType::ClassOrInterfaceType
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

    def data_type
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

