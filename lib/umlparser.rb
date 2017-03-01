class Object
  alias_method :rbmethods, :methods
  def _
    rbmethods.sort.join(',  ')
  end
end

require 'pry'
require 'java'
require 'open3'
require_relative 'javaparser-core-3.0.1.jar'

require_relative 'umlparser/version'
require_relative 'umlparser/ast'
require_relative 'umlparser/node'
require_relative 'umlparser/class_node'
require_relative 'umlparser/interface_node'
require_relative 'umlparser/attribute_node'
require_relative 'umlparser/method_node'
require_relative 'umlparser/constructor_node'
require_relative 'umlparser/uml_graph'

source = ARGV[0]
umlgraph_file = "#{source}.java"
dot_file = "#{source}.dot"
output_png = "#{source}.png"

ast = Umlparser::Ast.parse_files(source)
Umlparser::UmlGraph.new(ast).write(umlgraph_file)

commands = ["java", "-jar", "lib/umlgraph-5.7.2.23.jar", "-private", "-attributes", "-operations", "-types", "-visibility", "-output", dot_file, umlgraph_file]
output, status = Open3.capture2(*commands)
if status.exitstatus != 0
  # TODO Better exception
  raise 'Error'
end

commands = ["dot", "-T", "png", "-Gdpi=300", "-o", output_png, dot_file]

output, status = Open3.capture2(*commands)
#TODO Better output statements


