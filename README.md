# javaflame
The purpose of this project was to write a script that will generate Flame Graphs for all running java processes on the machine with minimal effort and without having to restart the Java processes and services.  By starting the java processes with the `-XX:+PreserveFramePointer` flag, we actually 

Heavily inspired by jmaps, by Brendan Gregg (13-Feb-2015)

https://github.com/brendangregg/Misc/blob/master/java/jmaps

Also

### Requirements
* Linux perf tools --> already setup in Jim Instances.
* The stackcollapse-perf.pl and flamegraph.pl programs come from:
   https://github.com/brendangregg/FlameGraph
* Java processes are required to have been started with the `-XX:+PreserveFramePointer` parameter.

### Usage - Optional Parameters
    Param 1: Sampling frequency (defaults to 99Hz)
    Param 2: Sample time        (defaults to 30s)
 
### How to interpret Flame Graphs
  http://www.slideshare.net/brendangregg/blazing-performance-with-flame-graphs/35

### Learn more
   http://techblog.netflix.com/2015/07/java-in-flames.html
