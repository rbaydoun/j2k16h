# javaflame
The purpose of this project was to write a script that will generate Flame Graphs for all running java processes on the machine with minimal effort and without having to restart the Java processes and services.  By starting the java processes with the `-XX:+PreserveFramePointer` flag, it is now possible to create "mixed mode" flame graphs (i.e., frame graphs with profile information from both system code path and Java code paths).

(See https://www.infoq.com/news/2015/08/JVM-Option-mixed-mode-profiles for details.)


This script is heavily inspired by jmaps, by Brendan Gregg (13-Feb-2015).  You can get it here:
https://github.com/brendangregg/Misc/blob/master/java/jmaps

### Requirements
* Linux perf tools --> already setup in Jim Instances.
* The stackcollapse-perf.pl and flamegraph.pl programs come from:
   https://github.com/brendangregg/FlameGraph
* Java processes are required to have been started with the `-XX:+PreserveFramePointer` parameter.
* If you're missing `less` : `sudo apt-get install less`
* If you're missing `linux-tools` : `sudo apt-get install linux-tools`

### Usage - Optional Parameters
Simply run with `sudo`

    Param 1: Sampling frequency (defaults to 99Hz)
    Param 2: Sample time        (defaults to 30s)

### Learn more and how to interpret Flame Graphs
   http://techblog.netflix.com/2015/07/java-in-flames.html
   
   Brendan Gregg LISA 2013 presentation:
   https://www.youtube.com/watch?v=nZfNehCzGdw
   
   Slides related to LISA 2013 presentation:
   http://www.slideshare.net/brendangregg/performance-tuning-ec2-instances/62
   
