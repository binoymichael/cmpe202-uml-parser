class Object
  alias_method :rbmethods, :methods
  def _
    rbmethods.sort.join(',  ')
  end
end

require 'pry'
require 'java'
require_relative 'javaparser-core-3.0.1.jar'

require_relative 'umlparser/version'
#require_relative 'umlparser/java_extensions'
require_relative 'umlparser/ast'
require_relative 'umlparser/node'
require_relative 'umlparser/class_node'
require_relative 'umlparser/interface_node'
require_relative 'umlparser/attribute_node'
require_relative 'umlparser/method_node'
require_relative 'umlparser/constructor_node'

source = ARGV[0]
ast = Umlparser::Ast.parse_files(source)
pp ast

__END__
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

        if child_props[:type] == :method 
          child_props[:parameters].each do |param_name, param_type|
            if ast.key?(param_type) && ast[param_type][:type] == :interface
              klass_props[:dependencies] << param_type
            end
          end
        end
      end
    end
  end

  def write(filename)
    scrub!
    pp ast
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
    header_string += " extends #{props[:extends][0]}" if props[:extends].any?
    header_string += " implements #{props[:implements].join(', ')}" if props[:implements].any?

    attributes = []
    associations = []
    dependencies = []
    props[:dependencies].each do |t|
      dependencies << " * @depend - - - #{t}"
    end

    props[:children].each do |child, c_props|
      next if c_props[:visibility] == false

      formatted_props = c_props.merge(name: child)
      formatted_props[:data_type] += '[]' if formatted_props[:is_collection]

      if c_props[:is_association]
        association_arity = c_props[:is_collection] ? '0..*' : '0..1'
        associations << [association_arity, c_props[:data_type]]
      else
        if c_props[:type] == :attribute
          attributes << "%{modifier} %{data_type} %{name};" % formatted_props
        elsif c_props[:type] == :method
          attributes << "%{modifier} %{data_type} %{name}(%{parameters});" %
                          formatted_props.merge(
                            parameters: formatted_props[:parameters].map { |k,v| "#{v} #{k}" }.join(', ')
                          )
        end
      end
    end
    uml_graph_templatify(header_string, attributes, associations, dependencies)
  end

  def uml_graph_templatify(header_string, attributes, associations, dependencies)
    lines = []
      lines << '/**'
      associations.each do |assoc|
        lines << " * @assoc - - #{assoc.first} #{assoc.last}"
      end
      dependencies.each do |d|
        lines << d
      end
      lines << ' */'

    lines << header_string
    lines << '{'
      attributes.each do |attribute|
        lines << "\t#{attribute}"
      end
    lines << '}'
    lines << "\n"
  end

end

ast = {}
source = ARGV[0]
Dir.glob("#{source}/*.java").each do |filename|
  cu = JavaParser.parse(File.read(filename))
  AstVisitor.new.visit(cu, ast)
end

output_file = "#{source}.java"
UmlGraph.new(@tree).write(output_file)
dot_file = "#{source}.dot"
output_png = "#{source}.png"


require 'open3'
commands = ["java", "-jar", "lib/umlgraph-5.7.2.23.jar", "-private", "-attributes", "-operations", "-types", "-visibility", "-output", dot_file]
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


