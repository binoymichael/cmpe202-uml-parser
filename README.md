[![Stories in Ready](https://badge.waffle.io/binoymichael/cmpe202-uml-parser.png?label=ready&title=Ready)](https://waffle.io/binoymichael/cmpe202-uml-parser)
# cmpe202-uml-parser
CMPE202 Project

# Class Diagram
Libraries used
  - JavaParser (https://github.com/javaparser/javaparser)
  - JRuby
  - UMLGraph
  - dot

Steps involved in creating the class diagram
  - I used JavaParser to parse the input *.java files. 
  - I wrote the main UML parser code in JRuby. My solution parses the java files into Abstract Syntax Tree (AST) like data structure. The specific rules specified by the Professor is then used to scrub and modify the AST data structure.
  - Finally an intermediate text file is created from the AST.
  - The intermediate file is then passed to the UMLGraph to generate a dot file.
  - The dot file is consumed by the dot utility to draw the final class diagram.

# Sequence Diagram
Libraries used
  - AspectJ
  - plotutils

Steps involved in creating the sequence diagram
  - AspectJ was used to create the sequence diagram
  - I wrote pointcuts in AspectJ to trace the method calls. 
  - This aspectj file is compiled along with the input java file with an AspectJ compiler. 
  - Running the compiled program generates a text file that can be consumed by UMLGraph to produce a sequence diagram. 
  - UMLGraph and the pic2plot utility in the plotutils package is finally used to draw the sequence diagram.

# Testing on an EC2 instance
##INSTRUCTIONS TO RUN APPLICATION:
- Access the app at http://ec2-54-153-108-151.us-west-1.compute.amazonaws.com/tenant-binoy/
- Login with the following credentials; username: tenant.binoy@parser.xyz password: password
- You can also Sign Up as a new user for different credentials
- Fill in the form with appropriate values and select a zip file to test. Click ‘Submit’ to generate the Class/Sequence diagram.

# Testing on a local environment
## Install pre-requisites
```
sudo apt-get install default-jre
sudo apt-get install graphviz
sudo apt-get install aspectj
sudo apt-get install plotutils
```

## Download test file for class diagram
```
sudo apt-get install unzip
curl -LO https://www.dropbox.com/s/tt2lo4il5qwzwmn/test1.zip
mkdir input
unzip test1.zip -d input
```

## Download parser script
```
curl -LO https://www.dropbox.com/s/rj8b73br7x5kwgq/parser.tar.gz
mkdir parser
tar -xvzf parser.tar.gz -C parser
```

## Download test file for sequence diagram
```
curl -LO https://www.dropbox.com/s/h8lj7igox1ao8mn/sequence.zip
mkdir sequence
unzip sequence.zip -d sequence
```

## Draw class diagram
```
cd parser
./umlparser.sh ../input test1
# The output will be present as a test1.png file
```

# Draw sequence diagram
```
./umlparser.sh -s ../sequence sequencetest
# The output will be present as a sequencetest.svg file
```

# Youtube Link showing demo (0:00 - 1:39)
https://www.youtube.com/watch?v=dMn6HZH-fcE
