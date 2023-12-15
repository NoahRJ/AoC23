#!/bin/zsh
# Created 12/15/23; NRJA

##############################
########## FUNCTIONS #########
##############################

##############################################
# Formats provided text with ###s to create
# section bodies + headers/footers
##############################################
function format_stdout() {
    body=${1}
    # Formats provided str with #s to create a header
    hashed_body="####### ${body} #######"
    # shellcheck disable=SC2051
    hashed_header_footer=$(printf '#%.0s' {1..$#hashed_body})
    echo "\n\n${hashed_header_footer}\n${hashed_body}\n${hashed_header_footer}\n"
}

##############################################
# Prompts for file until input is valid 
# Assigns:
#   Validated sequence filepath to ${filepath}
##############################################
function prompt_for_file() {
    read "sequence_from_file?
Drag 'n' drop sequence file below:
"
    if [[ -z ${sequence_from_file} || ! -f ${sequence_from_file} ]]; then
        echo "ERROR: No/invalid file provided!"
        echo "Press CTRL+C to exit"
        prompt_for_file
    fi
    format_stdout "FILEPATH VALID"
    filepath=${sequence_from_file}
}

##############################################
# Applies hash algorithm to provided val
# Arguments:
#   Input value; ${1}
# Returns:
#   Result once hash algo fully applied
##############################################
function hash_algorithm() {
    # Assign positional arg to input
    input=${1}
    # Set val to 0
    current_value=0
    # Set iter
    i=1

    # Iter over each character of the input
    while (( i <= ${#input} )); do
        # Arr subscript to get specific char
        char=${input[$i,$i]}
        # Apply algo to current character, adding/reassigning var
        current_value=$(( (current_value + ( $(printf '%d' "'${char}" ) )) * 17 % 256 ))
        # Increment counter
        let i++
    done

    # Return val once done looping
    echo ${current_value}
}

##############################################
# Prompts for input file, stores input as arr
# Iterate over, run algo, and sum
# Print to stdout and exit
# Returns:
#   Results sum from input to stdout
##############################################
function main() {

    format_stdout "LET'S GET JOLLY"

    # Init total_sum as 0
    total_sum=0
    
    # Assigns valid path to ${filepath}
    prompt_for_file

    # Read in seq from file
    sequence="$(cat ${filepath})"

    # Split on comma and assign to arr
    IFS=',' read -rA steps <<< "${sequence}"

    echo "Iterating over input..."

    # Iterate over steps, applying hash algo, and calculating sum
    count=0
    total=${#steps[@]}
    for step in "${steps[@]}"; do
        let count++
        # Only print progress every 100 loops
        if (( count % 100 == 0 )); then
            echo "Loop ${count}/${total}"
        fi
        # Strip newlines
        step=$(tr -d '\n' <<< ${step})
        # Apply hash algo
        result=$(hash_algorithm "${step}")
        # Add that shit
        total_sum=$((total_sum + result))
    done

    format_stdout "RESULTS SUM: ${total_sum}"
}

###############
##### MAIN ####
###############

main
