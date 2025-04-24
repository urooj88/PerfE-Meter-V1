**#############################      PerfE-Meter-V1       ####################################**

*********************************************************************************************************************************************************
				PerE-Meter-V1 on-line Energy Measurement tool on Linux
*********************************************************************************************************************************************************

**PerE-Meter:**	Measure the total energy consumption of data parallel kernel while running on the HPC platform and also calulate the Dynamic energy of th parallel kernel. 


**What is Perf:**

The perf tool is a Linux-specific, sample-based tool that uses CPU counters. Perf is a part of the Linux kernel (/tools/perf). The data sampled is displayed in the command-line interface.

Some of the features (also referred to as "events") in perf are:

Reading hardware events such as cache misses and CPU cycles
Reading software events such as page faults and CPU clocks
Finding other events (by running the command perf list):

1.	Hardware cache events
2.	Tracepoint events
3.	Hardware breakpoints

The commands I focus on are:

perf stat: Counts the events for the duration of the program
perf record: Gathers events (data) that can be used for a later report
perf report: Uses the data gathered by the record command and breaks down the events to functions.

**Required Software:**

1.	Perf.
2.	Linux OS(Ubuntu, Fedora, etc.)


**Help and Understang:**
Likwid is a simple to instal and use toolsuite of command-line applications and a library for performance-oriented programmers. For more details, there are some available links to get dived into it.

**Perf Examples:**
https://www.brendangregg.com/perf.html

**Perf Tool:**
https://perfwiki.github.io/main/tutorial/

**Getting Started with Perf:**
https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/getting-started-with-perf_monitoring-and-managing-system-status-and-performance#common-perf-commands_getting-started-with-perf

**Linux perf Command Examples:**
https://phoenixnap.com/kb/linux-perf

**Supported Architectures:**

1. Intel
2. AMD
3. ARM
4. IBM


**How To Use:**

sudo ./run_perf_energymeasure_pmxm.sh --app-type parallel








