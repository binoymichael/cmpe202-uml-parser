class Object
  alias_method :rbmethods, :methods
  def _
    rbmethods.sort.join(',  ')
  end
end

require 'java'
require 'open3'
require 'optparse'
require_relative 'javaparser-core-3.0.1.jar'
require_relative 'umlparser/version'
require_relative 'umlparser/ast'
require_relative 'umlparser/node_visitor'
require_relative 'umlparser/method_statement_visitor'
require_relative 'umlparser/node'
require_relative 'umlparser/class_node'
require_relative 'umlparser/interface_node'
require_relative 'umlparser/attribute_node'
require_relative 'umlparser/method_node'
require_relative 'umlparser/constructor_node'
require_relative 'umlparser/uml_graph'

ARGV.push('-h') unless ARGV.size == 2
options = {}
OptionParser.new do |opts|
  opts.banner = ["Usage: ./umlparser [options] <folder-with-java-files> <output-filename>",
                   "Draws class diagram by default."].join("\n")

  opts.on("-s", "--sequence", "Draw sequence diagram") do |s|
    options[:sequence] = s
  end
  opts.on("-h", "--help", "Show help") do 
    puts opts
    exit
  end
end.parse!

#unless options[:sequence]
  source = ARGV[0]
  output_file = ARGV[1]
  umlgraph_file = "#{output_file}.java"
  #dot_file = "#{output_file}.dot"
  #output_png = "#{output_file}.png"

  ast = Umlparser::Ast.parse_files(source)
  Umlparser::UmlGraph.new(ast).write(umlgraph_file)

  #commands = ["java", "-jar", "lib/umlgraph-5.7.2.23.jar", "-private", "-attributes", "-operations", "-types", "-visibility", "-output", dot_file, umlgraph_file]
  #output, status = Open3.capture2(*commands)
  #if status.exitstatus != 0
    ## TODO Better exception
    #raise 'Error'
  #end

  #commands = ["dot", "-T", "png", "-Gdpi=300", "-o", output_png, dot_file]
  #output, status = Open3.capture2(*commands)
  ##TODO Better output statements
#else
#end



