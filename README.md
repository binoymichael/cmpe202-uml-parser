[![Stories in Ready](https://badge.waffle.io/binoymichael/cmpe202-uml-parser.png?label=ready&title=Ready)](https://waffle.io/binoymichael/cmpe202-uml-parser)
# cmpe202-uml-parser
CMPE202 Project

# Install pre-requisites
```
sudo apt-get install default-jre
sudo apt-get install graphviz
sudo apt-get install aspectj
sudo apt-get install plotutils
```

# Download test file for class diagram
```
sudo apt-get install unzip
curl -LO https://www.dropbox.com/s/tt2lo4il5qwzwmn/test1.zip
mkdir input
unzip test1.zip -d input
```

# Download parser script
```
curl -LO https://www.dropbox.com/s/rj8b73br7x5kwgq/parser.tar.gz
mkdir parser
tar -xvzf parser.tar.gz -C parser
```

# Download test file for sequence diagram
```
curl -LO https://www.dropbox.com/s/h8lj7igox1ao8mn/sequence.zip
mkdir sequence
unzip sequence.zip -d sequence
```

# Draw class diagram
```
cd parser
./umlparser.sh ../input test1
```

# Draw sequence diagram
```
./umlparser.sh -s ../sequence sequencetest
```
