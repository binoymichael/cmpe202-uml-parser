require 'pry'
require 'java'
require_relative 'javaparser-core-3.0.1.jar'
java_import 'com.github.javaparser.JavaParser'

source = ARGV[0]
result = JavaParser.parse(File.read("#{source}/Main.java"))
binding.pry


#java_import 'Main'
#java_import 'TheEconomy'
#java_import 'Pessimist'

#class TheEconomy
  #def attach(*args)
    #puts 'hello'
  #end
#end
#binding.pry
#Main.main([])
