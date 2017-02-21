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
      extends: extended_types.map(&:to_s),
      implements: implemented_types.map(&:to_s),
    }
  end
end

class Java::ComGithubJavaparserAstBody::ConstructorDeclaration
  alias_method :simple_name, :name
  def name
    simple_name.identifier
  end

  def params
    Hash[parameters.map do |p|
      [p.name.to_s, p.type.to_s]
    end]
  end

  def properties
    {
      type: :constructor,
      modifier: modifiers.any? ? modifiers.first.name.downcase : nil,
      parameters: params,
    }
  end
end

class Java::ComGithubJavaparserAstBody::MethodDeclaration
  alias_method :simple_name, :name
  def name
    simple_name.identifier
  end

  def data_type
    type.to_s
  end

  def params
    Hash[parameters.map do |p|
      [p.name.to_s, p.type.to_s]
    end]
  end

  def properties
    {
      type: :method,
      modifier: modifiers.any? ? modifiers.first.name.downcase : nil,
      return_type: data_type,
      parameters: params,
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
    {
      type: :attribute,
      data_type: data_type,
      is_association: association?,
      is_collection: collection?,
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
    when Java::ComGithubJavaparserAstBody::MethodDeclaration
      tree[node.name] = node.properties
    when Java::ComGithubJavaparserAstBody::ConstructorDeclaration
      tree[node.name] = node.properties
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
