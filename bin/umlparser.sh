#!/bin/bash
BASEDIR=$(dirname "$0")
# Check for java
if [ -z `which java` ]; then
  echo "This program needs Java version 1.8 or above to work correctly. Please install it and retry.";
  exit 1;
fi

sequenceflag=false
usage () { echo "Usage: ./umlparser.sh [options] input-folder output-file";
           echo "";
           echo "Prints class diagram by default";
           echo "Use -s flag to draw sequence diagram instead"; }

while getopts ":sh" opt; do
  case ${opt} in
    h ) usage
      exit 0
      ;;
    s ) sequenceflag=true
      break;
      ;;
    \? ) usage
      exit 1
      ;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# -lt 2 ]] ; then
    usage
    exit 1
fi

if ! $sequenceflag
then
  # Check for graphviz
  if [ -z `which dot` ]; then
    echo "This program needs the graphviz package installed to work correctly. Please install it and retry."
    exit 1
  fi

  #Cleanup exisiting .java & .png files
  [ -e "$2.java" ] && rm "$2.java"
  [ -e "$2.png" ] && rm "$2.png"

  echo 'Preparing class diagram ...'
  java -jar "$BASEDIR/uml-class-diagram.jar" $1 $2
  echo "Drawing $2.png"
  java -jar "$BASEDIR/umlgraph-5.7.2.23.jar" -private -attributes -operations -types -visibility -output - "$2.java" | dot -Tpng -Gdpi=200 -o"$2.png" 
else
  # Check for ajc
  if [ -z `which ajc` ]; then
    echo "This program needs the aspectj compiler installed to work correctly. Please install it and retry."
    exit 1
  fi

  if [ -z `which pic2plot` ]; then
    echo "This program needs the plotutils package installed to work correctly. Please install it and retry."
    exit 1
  fi

  echo 'Preparing sequence diagram ...'
  tmpdir=`mktemp -d`
  cp "$1/"*".java" $tmpdir
  cp "$BASEDIR/TracingAspect.aj" $tmpdir
  ajc -1.8 $tmpdir/*.java $tmpdir/*.aj
  java -cp "$BASEDIR/aspectjrt-1.8.8.jar:$tmpdir" Main
  cp "$BASEDIR/sequence.pic" .
  pic2plot -Tsvg  uml.pic > "$2.svg.tmp"
  awk 'NR==1,/transform/{sub(/transform=".*" xml/, "transform=\"translate(0.25,0.05) scale(0.06, -0.06)\" xml")} 1' "$2.svg.tmp" > "$2.svg"

  # Cleaning up files
  rm sequence.pic
  rm -rf $tmpdir
  rm $2.svg.tmp
fi
