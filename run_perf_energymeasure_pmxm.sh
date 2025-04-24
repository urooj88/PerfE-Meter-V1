
###########################   PerfE-Meter-V1 (Wraper) #################################
#!/usr/bin/env python3

import subprocess  # For executing shell commands
import time  # For measuring time intervals
import argparse  # For handling command-line arguments
import os  # For interacting with the OS
import sys  # For system-related functionalities

#######################################################################
# Perf Parameters
#######################################################################

# Specify CPU cores to monitor (for example, cores 0-55)
CORES = "0-55"
# Define the energy performance monitoring counters to track (example counters)
ENERGY_PMCS = "power/energy-pkg/,power/energy-ram/"

# Output files to be deleted before running the measurements
OUTPUT_FILES = ["baseline_output.txt", "app_output.txt", "dynamic_energy_output.txt"]

# Function to delete previous output files
def delete_previous_output_files():
    """Delete previously saved output files"""
    for file in OUTPUT_FILES:
        if os.path.exists(file):
            print(f"Deleting previous output file: {file}...")  # Added message
            os.remove(file)
            print(f"{file} deleted successfully.")  # Confirmation message

def parse_perf_output(output):
    """Parse perf output to extract energy metrics"""
    print("\nRaw perf output:")
    print("=" * 50)
    print(output)
    print("=" * 50)
    
    metrics = {}
    
    # Extract energy values from the output
    lines = output.splitlines()
    for line in lines:
        if "power/energy-pkg/" in line:
            # Clean up the string and remove commas before converting to float
            pkg_energy = float(line.split()[0].replace(',', ''))  # Remove commas
            metrics['PKG_Energy'] = pkg_energy
            print(f"Found Package Energy: {pkg_energy:.2f} Joules")
        elif "power/energy-ram/" in line:
            # Clean up the string and remove commas before converting to float
            dram_energy = float(line.split()[0].replace(',', ''))  # Remove commas
            metrics['DRAM_Energy'] = dram_energy
            print(f"Found DRAM Energy: {dram_energy:.2f} Joules")
    
    return metrics

def measure_baseline():
    """Measure baseline energy using perf"""
    print("\nMeasuring Baseline Energy")
    print("=" * 50)
    
    # Run perf to measure power consumption while the system is idle
    cmd = f"sudo perf stat -a -e {ENERGY_PMCS} sleep 60"
    print(f"Running command: {cmd}")
    
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        metrics = parse_perf_output(result.stderr)  # We get energy data from stderr in perf
        
        if metrics:
            pkg_energy = metrics.get('PKG_Energy', 0)
            dram_energy = metrics.get('DRAM_Energy', 0)
            total_energy = pkg_energy + dram_energy
            
            # Calculate power consumption (Energy/Time)
            pkg_power = pkg_energy / 60
            dram_power = dram_energy / 60
            total_power = total_energy / 60
            
            # Display the baseline energy and power measurements
            print("\nBaseline Power Measurements:")
            print("=" * 40)
            print(f"Package Energy: {pkg_energy:.2f} J")
            print(f"DRAM Energy: {dram_energy:.2f} J")
            print(f"Total Energy: {total_energy:.2f} J")
            print(f"Package Power: {pkg_power:.2f} W")
            print(f"DRAM Power: {dram_power:.2f} W")
            print(f"Total Power: {total_power:.2f} W")
            
            # Write to file
            with open("baseline_output.txt", "w") as f:
                f.write(f"Package Energy: {pkg_energy:.2f} J\n")
                f.write(f"DRAM Energy: {dram_energy:.2f} J\n")
                f.write(f"Total Energy: {total_energy:.2f} J\n")
                f.write(f"Package Power: {pkg_power:.2f} W\n")
                f.write(f"DRAM Power: {dram_power:.2f} W\n")
                f.write(f"Total Power: {total_power:.2f} W\n")
            
            return {
                'pkg_energy': pkg_energy,
                'dram_energy': dram_energy,
                'total_energy': total_energy,
                'pkg_power': pkg_power,
                'dram_power': dram_power,
                'total_power': total_power
            }
    except Exception as e:
        print(f"Error measuring baseline: {e}")
        return None

def measure_application_energy(app_type):
    """Measure energy consumption while running an application"""
    if app_type == 'serial':
        app_cmd = "./run_smxm.sh"  # Serial application script
    else:
        app_cmd = "./run_pmxm.sh"  # Parallel application script
    
    cmd = f"sudo perf stat -a -e {ENERGY_PMCS} {app_cmd}"
    print(f"\nMeasuring Application Energy")
    print("=" * 50)
    print(f"Running command: {cmd}")
    
    try:
        start_time = time.time()
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        runtime = time.time() - start_time
        
        metrics = parse_perf_output(result.stderr)  # We get energy data from stderr in perf
        
        if metrics:
            pkg_energy = metrics.get('PKG_Energy', 0)
            dram_energy = metrics.get('DRAM_Energy', 0)
            total_energy = pkg_energy + dram_energy
            
            avg_pkg_power = pkg_energy / runtime
            avg_dram_power = dram_energy / runtime
            avg_total_power = total_energy / runtime
            
            # Display the application energy and power measurements
            print("\nApplication Power Measurements:")
            print("=" * 40)
            print(f"Runtime: {runtime:.2f} seconds")
            print(f"Package Energy: {pkg_energy:.2f} J ({avg_pkg_power:.2f} W avg)")
            print(f"DRAM Energy: {dram_energy:.2f} J ({avg_dram_power:.2f} W avg)")
            print(f"Total Energy: {total_energy:.2f} J ({avg_total_power:.2f} W avg)")
            
            # Write to file
            with open("app_output.txt", "w") as f:
                f.write(f"Runtime: {runtime:.2f} seconds\n")
                f.write(f"Package Energy: {pkg_energy:.2f} J ({avg_pkg_power:.2f} W avg)\n")
                f.write(f"DRAM Energy: {dram_energy:.2f} J ({avg_dram_power:.2f} W avg)\n")
                f.write(f"Total Energy: {total_energy:.2f} J ({avg_total_power:.2f} W avg)\n")
            
            return {
                'runtime': runtime,
                'pkg_energy': pkg_energy,
                'dram_energy': dram_energy,
                'total_energy': total_energy
            }
    except Exception as e:
        print(f"Error measuring application: {e}")
        return None

def calculate_dynamic_energy(baseline, app_metrics):
    """Calculate dynamic energy consumption"""
    print("\nDynamic Energy Calculation:")
    print("=" * 50)
    
    runtime = app_metrics['runtime']
    total_app_energy = app_metrics['total_energy']
    baseline_power = baseline['total_power']
    
    # Compute expected baseline energy
    expected_baseline = baseline_power * runtime
    dynamic_energy = total_app_energy - expected_baseline
    
    # Print dynamic energy calculation
    print(f"Expected Baseline Energy: {expected_baseline:.2f} J")
    print(f"Dynamic Energy: {dynamic_energy:.2f} J")
    
    # Write to file
    with open("dynamic_energy_output.txt", "w") as f:
        f.write(f"Expected Baseline Energy: {expected_baseline:.2f} J\n")
        f.write(f"Dynamic Energy: {dynamic_energy:.2f} J\n")
    
    return dynamic_energy

def main():
    # Delete previous output files before starting the measurements
    delete_previous_output_files()

    parser = argparse.ArgumentParser(description='Measure application energy consumption using perf')
    parser.add_argument('--app-type', choices=['serial', 'parallel'], default='serial',
                        help='Type of application to run (default: serial)')
    
    args = parser.parse_args()
    
    baseline = measure_baseline()
    if not baseline:
        return
    
    app_metrics = measure_application_energy(args.app_type)
    if not app_metrics:
        return
    
    dynamic_energy = calculate_dynamic_energy(baseline, app_metrics)
    print(f"\nFinal Dynamic Energy Consumption: {dynamic_energy:.2f} J")

if __name__ == "__main__":
    main()

