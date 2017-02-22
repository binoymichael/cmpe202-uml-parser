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
      visibility: true,
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
      visibility: true,
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
      visibility: true,
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



class UmlGraph
  attr_accessor :ast
  def initialize(ast)
    @ast = ast.dup
  end

  def scrub!
    ast.each do |klass_name, klass_props|
      klass_props[:children].each do |child_name, child_props|
        if child_props[:type] == :attribute && child_props[:is_association] && child_props[:visibility]
          # check for reverse associations
          data_type = child_props[:data_type] 
          if ast.key?(data_type)
            reverse_associations = ast[data_type][:children].select do |k, v|
                                      v[:data_type] == klass_name && 
                                      v[:type] == :attribute &&
                                      v[:is_association]
                                   end
            reverse_associations.each do |k, v|
              ast[data_type][:children][k][:visibility] = false
            end
          else
            # Make association an inline attribute if not present at AST root level
            child_props[:is_association] = false
          end
        end
      end
    end
  end

  def write(filename)
    scrub!
    File.open(filename, 'w') do |f|
      result = []
      ast.each do |klass, props|
        uml_graph(klass, props).each do |line|
          f.puts line
        end
      end
    end
    #puts result
  end

  def uml_graph(klass, props)
    header_string = "%{modifier} %{type} %{name}" % {modifier: props[:modifier], type: props[:type], name: klass}
    attributes = []
    associations = []

    props[:children].each do |child, c_props|
      next if c_props[:visibility] == false

      formatted_props = c_props.merge(name: child)
      formatted_props[:data_type] += '[]' if formatted_props[:is_collection]

      if c_props[:is_association]
        association_arity = c_props[:is_collection] ? '0..*' : '0..1'
        associations << [association_arity, c_props[:data_type]]
      else
        attributes << "%{modifier} %{data_type} %{name};" % formatted_props
      end
    end
    uml_graph_templatify(header_string, attributes, associations)
  end

  def uml_graph_templatify(header_string, attributes, associations)
    lines = []
    if associations.any?
      lines << '/**'
      associations.each do |assoc|
        lines << " * @assoc - - #{assoc.first} #{assoc.last}"
      end
      lines << ' */'
    end

    lines << header_string
    lines << '{'
      attributes.each do |attribute|
        lines << "\t#{attribute}"
      end
    lines << '}'
    lines << "\n"
  end

end

@tree = {}
source = ARGV[0]
Dir.glob("#{source}/*.java").each do |filename|
  cu = JavaParser.parse(File.read(filename))
  AstVisitor.new.visit(cu, @tree)
end

output_file = "#{source}.java"
UmlGraph.new(@tree).write(output_file)
dot_file = "#{source}.dot"
output_png = "#{source}.png"


require 'open3'
commands = ["java", "-jar", "lib/umlgraph-5.7.2.23.jar", "-private", "-attributes", "-types", "-visibility", "-output", dot_file]
commands << output_file
output, status = Open3.capture2(*commands)
puts output            # -> "hello; rm -rf *\n"
puts status.pid        # 123 or the process id
puts status.exitstatus # 0


commands = ["dot", "-T", "png", "-o", output_png, dot_file]
p commands.join(' ')
output, status = Open3.capture2(*commands)
puts output            # -> "hello; rm -rf *\n"
puts status.pid        # 123 or the process id
puts status.exitstatus # 0


