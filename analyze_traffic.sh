#!/bin/bash

########################################
# Bash Script to Analyze Network Traffic
########################################

# Function to check Everything is OK before start Analyzing the Traffic  
Check (){

    # Check if tshark is installed
    if ! command -v tshark &> /dev/null; then # Redirects both stdout and stderr to /dev/null
        echo "Error: tshark (from Wireshark package) is required but not installed."
        exit 1
    fi

    # Check if input file is provided
    if [ $# -eq 0 ]; then
        echo "Usage: $0 <pcap_file>"
        exit 1
    fi

    PCAP_FILE=$1

    # Check if file exists
    if [ ! -f "$PCAP_FILE" ]; then  # -f used for Regular file 
        echo "Error: File $PCAP_FILE not found!"
        exit 1
    fi

}

# Function to extract information from the pcap file
Analyze_traffic() {

    # Generate report
    echo "----- Network Traffic Analysis Report -----"
    #counts the total number of packets in the given PCAP file because tshark outputs one line per packet by default
    echo -e "\n1. Total Packets: $(tshark -r "$PCAP_FILE" | wc -l)"

    # Protocol breakdown
    echo -e "\n2. Protocols:"
    # Count HTTP packets
    HTTP_COUNT=$(tshark -r "$PCAP_FILE" -Y "http" 2>/dev/null | wc -l) # Redirects stderr to /dev/null

    # Count HTTPS (TLS) packets
    HTTPS_COUNT=$(tshark -r "$PCAP_FILE" -Y "tls" 2>/dev/null | wc -l) # Redirects stderr to /dev/null
    echo "   - HTTP Packets:  $HTTP_COUNT"
    echo "   - HTTPS Packets: $HTTPS_COUNT"

    # Top 5 Source IPs
    echo -e "\n3. Top 5 Source IP Addresses:"
    # Sorts the src IP addresses alphabetically (required for uniq -c to work correctly)
    # Counts occurrences of each unique IP address
    # Sorts lines numerically (-n) in reverse order (-r)
    # Keeps only the top  5 lines (IPs with the highest packet counts) -> output at each line "IP_Count IP"
    # Formatting
    tshark -r "$PCAP_FILE" -T fields -e ip.src 2>/dev/null | \
        sort     | uniq -c  | sort -nr | head -5  | \
        awk '{printf "   - %s: %d packets\n", $2, $1}'

    # Top 5 Destination IPs
    echo -e "\n4. Top 5 Destination IP Addresses:"
    # Sorts the src IP addresses alphabetically (required for uniq -c to work correctly)
    # Counts occurrences of each unique IP address
    # Sorts lines numerically (-n) in reverse order (-r)
    # Keeps only the top  5 lines (IPs with the highest packet counts) -> output at each line "IP_Count IP"
    # Formatting
    tshark -r "$PCAP_FILE" -T fields -e ip.dst 2>/dev/null | \
        sort     | uniq -c  | sort -nr | head -5  | \
        awk '{printf "   - %s: %d packets\n", $2, $1}'

    echo ""
    echo "----- End of Report -----"
}

# Run the checking function
Check "$1"
# Run the analysis function
Analyze_traffic
