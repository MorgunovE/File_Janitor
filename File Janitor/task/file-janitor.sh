#!/usr/bin/env bash

echo "File Janitor, $(date +%Y)"
echo "Powered by Bash"

filetypes=("log" "tmp" "py")

function find_files {
    local dir=$1
    for i in "${filetypes[@]}"; do
        num_files=$(find "$dir" -maxdepth 1 -type f -name "*.$i" | wc -l)
        total_size=$(find "$dir" -maxdepth 1 -type f -name "*.$i" -exec cat {} \; | wc -c)
        echo "$num_files $i file(s), with total size of $total_size bytes"
    done;
}

function delete_files {
    local dir=$1
    for i in "${filetypes[@]}"; do
        num_files=$(find "$dir" -maxdepth 1 -type f -name "*.$i" | wc -l)
        if [[ "$i" == "tmp" ]]; then
            echo "Deleting temporary files...  done! $num_files files have been deleted"
            find "$dir" -maxdepth 1 -type f -name "*.$i" -exec rm -rf {} \;

        elif [[ $i == "log" ]]; then
            num_files=$(find "$dir" -maxdepth 1 -type f -name "*.$i" -mtime +3 | wc -l)
            echo "Deleting old log files...  done! $num_files files have been deleted"
            find "$dir" -maxdepth 1 -type f -name "*.$i" -mtime +3 -exec rm -f {} \;
        else
            if [[ ! -d "$dir/python_scripts" && num_files -gt 0 ]]; then
                mkdir "$dir/python_scripts"
            fi;
            echo "Moving python files...  done! $num_files files have been moved"
            find "$dir" -maxdepth 1 -type f -name "*.$i" -exec mv {} "$dir/python_scripts" \;
        fi;
    done
    #echo -e "\nClean up of the current directory is complete!"
}

case "$1" in
    "help")
        cat file-janitor-help.txt;;
    "list")
        if [[ -z "$2" ]]; then
            echo -e "\nListing files in the current directory\n"
            ls -Av1
        elif [[ -d "$2" ]]; then
            echo -e "\nListing files in $2\n"
            ls -Av1 "$2"
        elif [ -f "$2" ]; then
            echo -e "\n$2 is not a directory\n"
        else
            echo -e "\n$2 is not found\n"
        fi;;
    "report")
        if [[ -z "$2" ]]; then
            echo -e "\nThe current directory contains:\n"
            find_files "."
        elif [[ -d "$2" ]]; then
            echo -e "\n$2 contains:\n"
            find_files "$2"
        elif [[ -f "$2" ]]; then
            echo -e "\n$2 is not a directory\n"
        else
            echo -e "\n$2 is not found\n"
        fi;;
    "clean")
        if [[ -z "$2" ]] ; then
            echo -e "\nCleaning the current directory...\n"
            delete_files "./"
        elif [[ -d "$2" ]] ; then
            echo -e "\nCleaning $2..."
            delete_files "$2"
        elif [[ -f "$2" ]]; then
            echo -e "\n$2 is not a directory\n"
        else
            echo -e "\n$2 is not found\n"
        fi;;
    *)
        echo -e "\nType $0 help to see available options\n";;
esac