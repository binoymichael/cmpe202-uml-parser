require 'pry'
require 'java'
require_relative 'javaparser-core-3.0.1.jar'

java_import 'com.github.javaparser.JavaParser'
java_import 'com.github.javaparser.ast.visitor.TreeVisitor'


class AstVisitor < TreeVisitor
  def process(node)
    p node.class
  end
end

java_file_contents = File.read('Hello.java')

cu = JavaParser.parse(java_file_contents)
AstVisitor.new.visitDepthFirst(cu)

