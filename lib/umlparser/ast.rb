java_import 'com.github.javaparser.JavaParser'
java_import 'com.github.javaparser.ast.visitor.VoidVisitorAdapter'


module Umlparser
  class Ast
    def self.parse_files(directory)
      ast = {}
      Dir.glob("#{directory}/*.java").each do |filename|
        compilation_unit = JavaParser.parse(File.read(filename))
        NodeVisitor.new.visit(compilation_unit, ast)
      end
      return ast
    end
  end
end
