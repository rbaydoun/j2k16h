# Heavily inspired by jmaps, by Brendan Gregg (13-Feb-2015)
# https://github.com/brendangregg/Misc/blob/master/java/jmaps

# Requirements:
#   Linux perf tools.
# 	The stackcollapse-perf.pl and flamegraph.pl programs come from:
# 	  https://github.com/brendangregg/FlameGraph
#
# Usage -- Param 1: Sampling frequency (defaults to 99Hz)
#          Param 2: Sample time        )defaults to 30s)
#
# How to interpret Flame Graphs
# http://www.slideshare.net/brendangregg/blazing-performance-with-flame-graphs/35

JAVA_HOME=/usr/lib/jvm/j2sdk1.8-oracle
FLAME_GRAPH_HOME=./FlameGraph-master
AGENT_HOME=$JAVA_HOME
PERF_CMD=/usr/bin/perf_3.2

# Validate parameters and set default values if missing.
if [ -z "$1" ]; then
	FREQUENCY=99
else
	FREQUENCY=$1
fi

if [ -z "$2" ]; then
	SLEEP_TIME=30
else
	SLEEP_TIME=$2
fi

# Validation...
if [ "$USER" != root ]; then
	echo "ERROR: not root user? exiting..."
	exit
fi

if [ ! -x $JAVA_HOME ]; then
	echo "ERROR: JAVA_HOME not set correctly; edit $0 and fix"
	exit
fi

if [ ! -x $AGENT_HOME ]; then
	echo "ERROR: AGENT_HOME not set correctly; edit $0 and fix"
	exit
fi

if [ ! -x $FLAME_GRAPH_HOME ]; then
	echo "ERROR: FLAME_GRAPH_HOME not set correctly; edit $0 and fix"
	exit
fi

if [ ! -x $PERF_CMD ]; then
	echo "ERROR: PERF_CMD not set correctly; edit $0 and fix"
	exit
fi

# figure out where the agent files are:
AGENT_OUT=""
AGENT_JAR=""
if [ -e $AGENT_HOME/out/attach-main.jar ]; then
	AGENT_JAR=$AGENT_HOME/out/attach-main.jar
elif [ -e $AGENT_HOME/attach-main.jar ]; then
	AGENT_JAR=$AGENT_HOME/attach-main.jar
fi

if [ -e $AGENT_HOME/out/libperfmap.so ]; then
	AGENT_OUT=$AGENT_HOME/out
elif [ -e $AGENT_HOME/libperfmap.so ]; then
	AGENT_OUT=$AGENT_HOME
fi


# Create output directory
mkdir ./flame_output

echo "Sampling perf_events at $FREQUENCY Hz for $SLEEP_TIME seconds..."
cmd="$PERF_CMD record -F $FREQUENCY -a -g -- sleep $SLEEP_TIME"
eval $cmd

# Backup the current directory.  Why doesn't pushd and popd work?
pwd_bk=$(pwd)

# For every java process, generate a flame graph.
for PID in $(pgrep -x jsvc); do
	# Find a previous map file and delete it.
	mapfile=/tmp/perf-$PID.map
	if [ -e $mapfile ]; then
		rm $mapfile
	fi

	echo "Generating map file $mapfile for PID $PID"

	# Generate a command string
	cmd="cd $AGENT_HOME; $JAVA_HOME/bin/java -Xms32m -Xmx128m -cp $AGENT_JAR:$JAVA_HOME/lib/tools.jar net.virtualvoid.perf.AttachOnce $PID"

	# If the process owner is different than root.
	user=$(ps ho user -p $PID)
	if [ "$user" != root ]; then
		# make $user the username if it is a UID:
		if [ "$user" == [0-9]* ]; then user=$(awk -F: '$3 == '$user' { print $1 }' /etc/passwd); fi
		cmd="su - $user -c '$cmd'"
	fi

	# run the command.
	eval $cmd

	if [ -e "$mapfile" ]; then
		chown root $mapfile
		chmod 666 $mapfile
	else
		echo "ERROR: $mapfile was not created for PID $PID."
	fi
done
cd $pwd_bk

# Generate temporary output file
cmd="$PERF_CMD script -f comm,pid,tid,cpu,time,event,ip,sym,dso,trace | $FLAME_GRAPH_HOME/stackcollapse-perf.pl --pid > output.tmp"
eval $cmd

# When done with all the maps, start generating Flame graphs.
for PID in $(pgrep -x jsvc); do
	host=$(hostname)
	date_time=$(date)
	title="$host - PID $PID @ $date_time"
	cmd="cat output.tmp | grep $PID | $FLAME_GRAPH_HOME/flamegraph.pl --color=java --title=\"$title\" --hash > \"./flame_output/$title.svg\""
	eval $cmd
done

# Clean up.
rm output.tmp

# Keep the perf data, it could be usefull for something else.
#rm perf.data