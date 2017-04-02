all: clean

clean: 
	find . -name "*.class" -exec rm -rf {} \;
	
compile:
	ajc -1.8 *.java *.aj

run: compile
	java -cp . Main


	
