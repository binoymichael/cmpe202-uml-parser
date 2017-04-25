[![Stories in Ready](https://badge.waffle.io/binoymichael/cmpe202-uml-parser.png?label=ready&title=Ready)](https://waffle.io/binoymichael/cmpe202-uml-parser)
# cmpe202-uml-parser
CMPE202 Project

# Create AST Tree
 - ruby lib/parser.rb test

# Make UML class diagram
  - java -jar lib/umlgraph-5.7.2.23.jar -private -attributes -visibility -output - uml.java | dot -Tpng -ograph.png


# Prerequisties
 - Java version 1.8 or above
 ```
 sudo apt-get install default-jre
 ```

 - Graphviz
 ```
 sudo apt-get install graphviz
 ```

 - AspectJ
 ```
 sudo apt-get install aspectj
 ```


