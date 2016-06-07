# javaflame
Heavily inspired by jmaps, by Brendan Gregg (13-Feb-2015)

https://github.com/brendangregg/Misc/blob/master/java/jmaps

### Requirements
* Linux perf tools --> already setup in Jim Instances.
* The stackcollapse-perf.pl and flamegraph.pl programs come from:
   https://github.com/brendangregg/FlameGraph
* Java processes are required to have been started with the “-XX:+PreserveFramePointer”

### Usage - Optional Parameters
    Param 1: Sampling frequency (defaults to 99Hz)
    Param 2: Sample time        (defaults to 30s)
 
### How to interpret Flame Graphs
  http://www.slideshare.net/brendangregg/blazing-performance-with-flame-graphs/35
