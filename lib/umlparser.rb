class Object
  alias_method :rbmethods, :methods
  def _
    rbmethods.sort.join(',  ')
  end
end

require 'pry'
require 'java'
require_relative 'javaparser-core-3.0.1.jar'

java_import 'com.github.javaparser.JavaParser'
java_import 'com.github.javaparser.ast.visitor.VoidVisitorAdapter'

class Java::ComGithubJavaparserAstBody::ClassOrInterfaceDeclaration
  alias_method :simple_name, :name
  def name
    simple_name.identifier
  end

  def properties
    {
      type: interface? ? :interface : :class,
      modifier: modifiers.any? ? modifiers.first.name.downcase : nil,
    }
  end
end

class Java::ComGithubJavaparserAstBody::VariableDeclarator
  alias_method :simple_name, :name
  def name
    simple_name.identifier
  end

  def data_type
    case type
    when Java::ComGithubJavaparserAstType::ClassOrInterfaceType
      if type.type_arguments.present?
        type.type_arguments.get.first.to_s
      else
        type.to_s
      end
    when Java::ComGithubJavaparserAstType::ArrayType
      type.element_type.to_s
    when Java::ComGithubJavaparserAstType::PrimitiveType
      type.to_s
    else
      type.to_s
    end
  end

  def association?
    case type.element_type
    when Java::ComGithubJavaparserAstType::ClassOrInterfaceType
      true
    else
      false
    end
  end

  def collection?
    case type
    when Java::ComGithubJavaparserAstType::ClassOrInterfaceType
      type.type_arguments.present?
    when Java::ComGithubJavaparserAstType::ArrayType
      true
    else
      false
    end
  end

  def properties
    #binding.pry
    {
      type: :attribute,
      data_type: data_type,
      is_association: association?,
      is_collection: collection?
    }
  end
end

class AstVisitor < VoidVisitorAdapter
  def visit(node, tree)
    case node
    when Java::ComGithubJavaparserAstBody::ClassOrInterfaceDeclaration
      children = {}
      tree[node.name] = node.properties.merge(children: children)
      super(node, children)
    when Java::ComGithubJavaparserAstBody::FieldDeclaration
      modifier = (m = node.modifiers).any? ? m.first.name.downcase : nil
      node.variables.each do |v|
        tree[v.name] = v.properties.merge(modifier: modifier)
      end
      super(node, tree)
    else
      super(node, tree)
    end
  end
end


#java_file_contents = File.read(ARGV[0])

@tree = {}
Dir.glob("#{ARGV[0]}/*.java").each do |filename|
  cu = JavaParser.parse(File.read(filename))
  AstVisitor.new.visit(cu, @tree)
end

pp @tree
