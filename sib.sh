#!/bin/bash

# Function to print header with color
print_header() {
    printf "\e[1;36m%-10s %-10s %-10s %-10s %-15s %-15s %-10s\e[0m\n" "PID" "PPID" "USER" "CPU%" "MEM%" "START TIME" "COMMAND"
}

# Function to print process info with color
print_process_info() {
    pid=$1
    ppid=$2
    user=$3
    cpu_percent=$4
    mem_percent=$5
    start_time=$6
    cmd=$7
    output_info=$8
    # Define colors
    pid_color="\e[1;37m" # White color for PID
    ppid_color="\e[1;37m" # White color for PPID
    user_color="\e[1;37m" # White color for USER
    cpu_color=$(get_cpu_color "$cpu_percent")
    mem_color=$(get_mem_color "$mem_percent")
    start_time_color="\e[1;37m" # White color for START TIME
    cmd_color="\e[1;35m" # White color for COMMAND
    output_info_color="\e[1;35m" # Magenta color for output info
    # Print process info with colors
    printf "$pid_color%-10s $ppid_color%-10s $user_color%-10s $cpu_color%-10.2f\e[0m $mem_color%-10.2f\e[0m $start_time_color%-15s $cmd_color%-10s\e[0m$output_info_color%-10s\e[0m\n" "$pid" "$ppid" "$user" "$cpu_percent" "$mem_percent" "$start_time" "$cmd" "$output_info"
}

# Function to get CPU color based on usage percentage
get_cpu_color() {
    local cpu_percent=$1
    if (( $(awk 'BEGIN {print ('$cpu_percent' >= 70.0)}') )); then
        echo "\e[1;31m" # Red color for high CPU usage
    elif (( $(awk 'BEGIN {print ('$cpu_percent' >= 30.0)}') )); then
        echo "\e[1;33m" # Yellow color for moderate CPU usage
    else
        echo "\e[0m" # Default color
    fi
}

# Function to get memory color based on usage percentage
get_mem_color() {
    local mem_percent=$1
    if (( $(awk 'BEGIN {print ('$mem_percent' >= 70.0)}') )); then
        echo "\e[1;31m" # Red color for high memory usage
    elif (( $(awk 'BEGIN {print ('$mem_percent' >= 30.0)}') )); then
        echo "\e[1;33m" # Yellow color for moderate memory usage
    else
        echo "\e[0m" # Default color
    fi
}

# Function to display help
display_help() {
	clear
    echo "Usage:"
    echo "  h - Display help"
    echo "  q - Quit"
     sleep 0.5
}

# Main function
main() {
    clear
    print_header
    while true; do
        processes=$(ps ax -o pid,ppid,user,%cpu,%mem,start,cmd --sort=-%cpu | head -n 11 | awk 'NR>1')
        while IFS= read -r line; do
            pid=$(echo "$line" | awk '{print $1}')
            ppid=$(echo "$line" | awk '{print $2}')
            user=$(echo "$line" | awk '{print $3}')
            cpu_percent=$(echo "$line" | awk '{print $4}')
            mem_percent=$(echo "$line" | awk '{print $5}')
            start_time=$(echo "$line" | awk '{print $6}')
            cmd=$(echo "$line" | awk '{$1="";$2="";$3="";$4="";$5="";$6=""; print $0}')
            output_info=$(echo "$line" | awk '{$1="";$2="";$3="";$4="";$5="";$6=""; printf "%s", $0}')
            print_process_info "$pid" "$ppid" "$user" "$cpu_percent" "$mem_percent" "$start_time" "$cmd" "$output_info"
        done <<< "$processes"
        read -t 1 -n 1 input
        clear
        print_header
        case $input in
            h)  display_help ;;
            q)  break ;;
            *)  ;;
        esac
    done
}

# Run the main function
main
