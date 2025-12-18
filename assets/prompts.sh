#!/bin/bash

center_text_prompt() {
    local term_width=$(tput cols)
    local line="$1"
    local stripped=$(echo "$line" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')  # strip ANSI codes
    local padding=$(( (term_width - ${#stripped}) / 2 ))
    printf "%*s%s\n" "$padding" "" "$line"
}

show_prompt() {
    local challenge_num=$1
    local prompt_file="$SCRIPT_DIR/../assets/prompts.sh"
    local in_block=0

    while IFS= read -r line; do
        trimmed=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        if [[ "$trimmed" == "# Challenge $challenge_num" ]]; then
            in_block=1
            continue
        fi

        if [[ "$in_block" -eq 1 && "$trimmed" =~ ^#\ Challenge\ [0-9]+$ ]]; then
            break
        fi

        if [[ "$in_block" -eq 1 ]]; then
            center_text_prompt "$line"
        fi
    done < "$prompt_file"

    echo
    read -p "Press Enter to begin..."
}


# Challenge 1
Greeting the User by Name

Objective:
Write a Bash script that asks the user for their name and then greets them with a personalized message.

Requirements:
- The script must display the message:
  What is your name?
  but without moving to the next line immediately (i.e., the cursor should remain on the same line as the input).
- Wait for the user to enter their name and store it in a variable called name.
- After the user types their name and presses Enter, the script should display:
  Hello, <name>!
  where <name> is the name the user typed.

Example Run:
What is your name? 
(user inputs "Sam")
Hello, Sam!

Tips:
- Use `echo -n` to display text without a newline.
- Use the `read` command to capture input from the user.
- To insert the value of a variable in a string, use double quotes and `$variable_name`.

# Challenge 2
Prompt the user for two numbers and print their sum.

# Challenge 3
Check if the user provided input. If not, print a warning.

# Challenge 4
Check if a file exists. If it doesn’t, create it.

# Challenge 5
Print all even numbers from 1 to 10.

# Challenge 6
Print the current date and time: "Current date and time: Wed Jul  9 23:00:31 EDT 2025"

# Challenge 7
Create a script that checks if a directory exists, and if not, creates it.

# Challenge 8
Write a script to read a file line by line and print each line.

# Challenge 9
Prompt the user to enter a directory name. If the directory exists, print "Directory exists." Otherwise, print "Directory does not exist."

# Challenge 10
Use a loop to print numbers 10 to 1 in reverse order.

# Challenge 11
Prompt the user for a filename and delete it if it exists.

# Challenge 12
Check if a user exists on the system.

# Challenge 13
Write a script that appends user input to a text file.

# Challenge 14
Create a script that renames a file based on user input.

# Challenge 15
Print only the odd numbers from 1 to 20.

# Challenge 16
Print the first 10 lines of a file specified by the user.

# Challenge 17
Write a script that creates a backup of a given file.

# Challenge 18
Prompt the user to enter a number, then calculate and print its square.

# Challenge 19
Print all files in the current directory with a .txt extension.

# Challenge 20
Write a script that lists all hidden files in the current directory.

# Challenge 21
Write a script that checks whether a number is even or odd.

# Challenge 22
Display the total number of files in the current directory.

# Challenge 23
Prompt the user for a string and print its length.

# Challenge 24
Print the names of all users currently logged in.

# Challenge 25
Find and delete all .tmp files in the current directory.

# Challenge 26
Create a countdown timer from 10 to 1 with 1-second intervals.

# Challenge 27
Print the content of a file in reverse line order.

# Challenge 28
Replace all instances of \foo\ with \bar\ in a file.

# Challenge 29
Write a script to check disk usage of the home directory.

# Challenge 30
Create a new file and add a shebang line and basic comments.

# Challenge 31
Display the current user’s home directory.

# Challenge 32
Print the system's uptime.

# Challenge 33
Prompt for a number and print its factorial.

# Challenge 34
Create a function that adds two numbers and call it.

# Challenge 35
Write a script that extracts all unique words from a file.

# Challenge 36
Find and replace a string in multiple files.

# Challenge 37
Generate a random number between 1 and 100.

# Challenge 38
Check if a service is running and print its status.

# Challenge 39
Print all command-line arguments passed to a script.

# Challenge 40
Write a script that calculates the sum of all digits in a number.

# Challenge 41
List all running processes that contain a given string.

# Challenge 42
Prompt for a directory and count all files inside it.

# Challenge 43
Write a script to display the current system date in YYYY-MM-DD format.

# Challenge 44
Make a script that pings a website and prints if it’s reachable.

# Challenge 45
Prompt for a filename and check if it’s readable, writable, or executable.

# Challenge 46
Create a script that shows the last 5 commands run in your shell.

# Challenge 47
Print the size of a given file in bytes.

# Challenge 48
Append the output of the date command to a log file.

# Challenge 49
Use a loop to print each character of a string.

# Challenge 50
Print the current shell’s PID.

# Challenge 51
 Write a script to compare two numbers and print the greater one.

# Challenge 52
 Loop through a list of words and print each one on a new line.

# Challenge 53
 Read from stdin and write the input to a file.

# Challenge 54
 Simulate a progress bar with sleep commands.

# Challenge 55
 Print the current month and year.

# Challenge 56
 Count the number of lines in a file.

# Challenge 57
 Prompt for a filename and display its permissions.

# Challenge 58
 Remove duplicate lines from a file.

# Challenge 59
 Ask for a number and print whether it's prime.

# Challenge 60
 Use seq to print numbers 1 through 100.

# Challenge 61
 Write a script that checks for updates on a Debian system.

# Challenge 62
 Simulate a coin toss using random numbers.

# Challenge 63
 Prompt the user for a word and print it in uppercase.

# Challenge 64
 Create a calculator script that supports +, -, *, /.

# Challenge 65
 Display the hostname of the machine.

# Challenge 66
 Print the current user's groups.

# Challenge 67
 Archive a directory into a .tar.gz file.

# Challenge 68
 Extract the file extension from a given filename.

# Challenge 69
 Print the N-th line of a file.

# Challenge 70
 Sort a list of numbers stored in a file.

# Challenge 71
 Print a triangle of stars using nested loops.

# Challenge 72
 Reverse a string provided by the user.

# Challenge 73
 Create a directory structure with subfolders.

# Challenge 74
 Print only filenames larger than 1MB in a directory.

# Challenge 75
 Prompt for a process name and kill it.

# Challenge 76
 Display the path of all .sh files recursively.

# Challenge 77
 Copy all .txt files from one directory to another.

# Challenge 78
 Display all lines from a file that contain a given word.

# Challenge 79
 Find the largest file in a directory.

# Challenge 80
 Simulate a dice roll and print the result (1–6).

# Challenge 81
 Print the total size of all files in the current directory.

# Challenge 82
 Create a script that counts how many users are currently logged in.

# Challenge 83
 Write a script that checks if a number is positive, negative, or zero.

# Challenge 84
 Create a script that displays the first and last lines of a file.

# Challenge 85
 Print all environment variables in sorted order.

# Challenge 86
 Create a script that finds all broken symbolic links in a directory.

# Challenge 87
 Ask the user for a command and check if it’s installed.

# Challenge 88
 Display a list of users sorted by their user ID.

# Challenge 89
 Write a script that es each word of a sentence on a new line.

# Challenge 90
 Show the number of running background jobs.

# Challenge 91
 Create a script that validates an email address format.

# Challenge 92
 Find all empty files in the current directory and its subdirectories.

# Challenge 93
 Prompt the user for a string and count the number of vowels.

# Challenge 94
 Display the current working directory without using pwd.

# Challenge 95
 Print the current time in HH:MM:SS format every second for 5 seconds.

# Challenge 96
 Create a script that prints a calendar for the current month.

# Challenge 97
 Replace all spaces in a filename with underscores.

# Challenge 98
 Compare two files and print whether they are identical.

# Challenge 99
 Write a script that finds and prints the longest word in a file.

# Challenge 100
 Print your current IP address.

# Challenge 101
 Print a list of files sorted by modification date.

# Challenge 102
 Prompt the user for a sentence and count how many words it contains.

# Challenge 103
 Use a case statement to respond to user input: yes/no.

# Challenge 104
 List the names and sizes of all files in a given directory.

# Challenge 105
 Prompt the user for a URL and check if the site is reachable.

# Challenge 106
 Count how many times a given word appears in a file.

# Challenge 107
 Create a script that monitors CPU usage.

# Challenge 108
 Display the file permissions in symbolic and octal form.

# Challenge 109
 Remove all comments (lines starting with #) from a script.

# Challenge 110
 Prompt the user for input and save it with a timestamp.

# Challenge 111
 Display the full path of the script being executed.

# Challenge 112
 Create a script that renames all .txt files to .bak.

# Challenge 113
 Check if a number is divisible by another number.

# Challenge 114
 Display only the IP address of your default gateway.

# Challenge 115
 Prompt for a file and check if it’s a regular file, directory, or symlink.

# Challenge 116
 List all users whose shell is /bin/bash.

# Challenge 117
 Create a countdown from a user-specified number to 0.

# Challenge 118
 Print all filenames in a directory that contain digits.

# Challenge 119
 Display the memory usage of the system.

# Challenge 120
 Create a to-do list script that lets the user add and list items.

# Challenge 121
 Extract the username from an email address.

# Challenge 122
 Create a script that simulates a loading spinner.

# Challenge 123
 Find and print all palindromes in a given file.

# Challenge 124
 Count the number of files modified in the last 24 hours.

# Challenge 125
 Create a script to convert a string to lowercase.

# Challenge 126
 Prompt for a number and check if it is a perfect square.

# Challenge 127
 Display the permissions of a file in human-readable form.

# Challenge 128
 Write a script that simulates a simple login with a password prompt.

# Challenge 129
 Display the number of CPUs in the system.

# Challenge 130
 Prompt the user for a string and check if it is a palindrome.

# Challenge 131
 Find all lines in a file that are longer than 80 characters.

# Challenge 132
 List all shell scripts in a directory and its subdirectories.

# Challenge 133
 Create a stopwatch script that tracks elapsed time until you press a key.

# Challenge 134
 Print the name of the current terminal device.

# Challenge 135
 Write a script to monitor a file and alert if it changes.

# Challenge 136
 Create a script that prints the username and full name of the current user.

# Challenge 137
 Sort all lines in a file alphabetically.

# Challenge 138
 Create a script that prints all prime numbers from 1 to 100.

# Challenge 139
 Prompt the user for two times and calculate the difference in minutes.

# Challenge 140
 Write a script that renames all files to lowercase.

# Challenge 141
 Print your public IP address using a web service.

# Challenge 142
 Check if a user-specified port is open on localhost.

# Challenge 143
 Print a histogram of word lengths from a given file.

# Challenge 144
 Trim leading and trailing spaces from a user input string.

# Challenge 145
 Create a menu that lets the user choose between options 1–3 and acts accordingly.

# Challenge 146
 Display the number of running and sleeping processes.

# Challenge 147
 Print all lines in a file that contain numbers.

# Challenge 148
 Create a script to compare the contents of two directories.

# Challenge 149
 Replace tabs with spaces in a given file.

# Challenge 150
 List all installed packages (Debian-based systems).

# Challenge 151
 Create a script that logs user input with timestamps to a file.

# Challenge 152
 Display the total disk usage of each subdirectory.

# Challenge 153
 Print the date one week from today.

# Challenge 154
 Find all symbolic links in a directory and verify if they point to valid targets.

# Challenge 155
 Create a quiz game that asks the user a multiple-choice question.

# Challenge 156
 Display the kernel version and operating system info.

# Challenge 157
 Count the number of files by extension in the current directory.

# Challenge 158
 Prompt the user to enter a directory and check if it's writable.

# Challenge 159
 Generate a random password of a given length.

# Challenge 160
 Create a countdown script that shows remaining time in MM:SS format.

# Challenge 161
 Prompt the user for a file and print the number of words it contains.

# Challenge 162
 Display all IP addresses assigned to your machine.

# Challenge 163
 Create a script that logs the system uptime every minute.

# Challenge 164
 Check if the current user has sudo privileges.

# Challenge 165
 Write a script that compresses a file using gzip and reports the size savings.

# Challenge 166
 Prompt the user for a number and print its multiplication table up to 10.

# Challenge 167
 Create a script that exits with code 0, 1, or 2 based on user input.

# Challenge 168
 Generate a random alphanumeric string of a given length.

# Challenge 169
 List the top 5 largest files in the current directory.

# Challenge 170
 Display all background processes started by the current user.

# Challenge 171
 Simulate flipping a coin 10 times and print the result of each flip.

# Challenge 172
 Prompt for a phrase and print it centered in the terminal window.

# Challenge 173
 Create a script that outputs the number of active network connections.

# Challenge 174
 Remove all files older than 7 days in a given directory.

# Challenge 175
 Display the SHA256 hash of a file specified by the user.

# Challenge 176
 Print each environment variable name and its value on a new line.

# Challenge 177
 Prompt for a string and remove all punctuation marks from it.

# Challenge 178
 Monitor changes to a file and print new lines as they are added.

# Challenge 179
 Ask for a filename and print its contents in uppercase.

# Challenge 180
 Create a script that renames files by adding a timestamp prefix.

# Challenge 181
 Write a script to convert temperatures from Celsius to Fahrenheit.

# Challenge 182
 Print all users who logged in today.

# Challenge 183
 Create a script that compares the sizes of two files.

# Challenge 184
 Prompt for a filename and count how many lines it has.

# Challenge 185
 Use a select loop to create a simple menu system.

# Challenge 186
 Extract only email addresses from a text file.

# Challenge 187
 Create a script that measures how long a command takes to run.

# Challenge 188
 Print a list of open network ports and the associated services.

# Challenge 189
 Prompt the user to enter a URL and download the page source.

# Challenge 190
 Write a script that checks if a website is HTTPS-secured.

# Challenge 191
 Find the most frequently used command in your history.

# Challenge 192
 List all mounted file systems and their usage.

# Challenge 193
 Display the date and time in RFC 2822 format.

# Challenge 194
 Prompt for a number and print whether it is a prime number.

# Challenge 195
 Convert a decimal number to binary.

# Challenge 196
 Create a script to send a desktop notification.

# Challenge 197
 Check internet connectivity by pinging a reliable host.

# Challenge 198
 Find and list all duplicate files in a directory.

# Challenge 199
 Create a script that creates a timestamped log entry.

# Challenge 200
 Build a simple text-based calculator using functions.

# Challenge 201
Prompt the user for a network interface (like eth0 or wlan0), then show its MAC address using the /sys/class/net/<interface>/address file. Example output: "The MAC address for eth0 is: 01:23:45:67:89:ab"

# Challenge 202
Disk Usage Audit and Large File Finder

Objective:  
Write a Bash script that generates a basic disk usage report for the system, showing:
1. Overall disk space usage for the root filesystem (`/`)
2. The 10 largest directories in the root filesystem
3. A list of files over 100MB in size

Requirements:
- Use the `df` command to show disk usage (human-readable format) for `/`
- Use `du` with `sort` to list the top 10 largest directories at the root level
- Use `find` to search for files larger than 100MB and display their names and sizes
- Suppress error messages for permission-denied paths using `2>/dev/null`
- Bonus: Format your script with clear section headings using `echo`

Example Run:
DISK USAGE SUMMARY  
Filesystem      Size  Used Avail Use% Mounted on  
/dev/sda1        20G   15G  4.5G  78% /  

TOP 10 LARGEST DIRECTORIES IN ROOT (/)  
1.2G    /usr  
800M    /var  
...

FILES OVER 100MB  
/home/user/Downloads/movie.mp4: 1.3G  
/var/log/archive.log: 250M  
...

Tips:
- Use `du -h --max-depth=1 /` to get directory sizes
- Use `sort -hr` to sort human-readable sizes in reverse
- Use `find / -type f -size +100M` to find files over 100MB
- Use `ls -lh` and `awk` to print file sizes cleanly

# Challenge 203
Triage a Live Linux System

Objective:
Write a Bash script that simulates a real-world system triage. The goal is to gather and display vital health information from a Linux server that might be under stress. This replicates how a junior sysadmin might assess a server in the first few minutes of a live incident.

Requirements:
- Display a header showing the current date/time in the format:
  SYSTEM TRIAGE REPORT — <current date>
- Show disk usage in human-readable format using: df -h
- Show memory usage using: free -h
- List the top 10 CPU-consuming processes using:
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 10
- Show all listening TCP/UDP ports, excluding 127.0.0.1:
  ss -tulwn | grep -v "127.0.0.1"
- Show system load and uptime using: uptime
- Show the last 20 lines of system logs using:
  journalctl -n 20 --no-pager
  - If journalctl fails, fall back to:
    tail -n 20 /var/log/syslog
- End the script with the message:
  Triage complete.

Bonus:
- Save the full report to a timestamped file in /tmp, e.g., /tmp/triage_2024-07-15_14-03-45.log
- Add a timer to show how long the script took to run

Example Output:
SYSTEM TRIAGE REPORT — Mon Jul 15 14:03:45 EDT 2025

 Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   28G   20G  59% /

 Memory Usage:
              total        used        free
Mem:           7.8G        2.5G        4.7G

 Top CPU Processes:
  PID  PPID  CMD              %MEM  %CPU
  122  1     /usr/bin/java    18.2  35.6
  103  1     /usr/bin/nginx    5.0  12.2
  ...

 Active Network Connections:
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:Port
tcp   LISTEN 0      128    0.0.0.0:22         0.0.0.0:*

 System Load and Uptime:
 14:03:45 up 5 days,  2:22,  1 user,  load average: 0.11, 0.08, 0.05

 Last 20 System Logs:
Jul 15 14:02:01 myhost CRON[1113]: pam_unix(cron:session): session opened
Jul 15 14:02:01 myhost CRON[1113]: pam_unix(cron:session): session closed
...

Triage complete.

Tips:
- Use echo -e "\n..." to add section headers with spacing.
- Redirect errors with 2>/dev/null to clean up output.
- Use date +%Y-%m-%d_%H-%M-%S to create unique filenames for log output.

# Challenge 204
Safely Modify a Configuration File

Objective:
Write a Bash script that safely performs a configuration change. This simulates a real-world scenario where a system script makes a potentially risky edit to a config file — and must back it up, validate the result, and restore it if the change fails.

Requirements:
- Set a variable called CONFIG_FILE that points to /etc/important.conf
- Create a backup of the file with a unique timestamp using:
  BACKUP_FILE="/etc/important.conf.bak.$(date +%s)"
- If the config file does not exist, display:
  Config file not found!
  and exit with code 1
- Copy the file to the backup location and echo:
  Backup created at <backup_path>
- Perform a simulated config change with:
  sed -i 's/Enabled=no/Enabled=yes/' "$CONFIG_FILE"
- Validate that the change worked by checking if the line “Enabled=yes” appears
  - If successful, display:
    Config change successful.
  - If the change fails, display:
    Config change failed. Restoring backup...
    and restore the original file from backup

Bonus:
- Accept the config path as an argument ($1), falling back to /etc/important.conf if not provided
- Log all actions and outcomes to a file in /tmp, e.g., /tmp/config_edit_203_<timestamp>.log
- Include a timestamp for every logged step

Example Run:
Backup created at /etc/important.conf.bak.1721060492  
Config change successful.

Tips:
- Use if [ ! -f "$file" ] to test for file existence
- Use `cp` to make the backup and restore the file if needed
- Use `grep -q` inside an if-statement to check if the change was successful
- Use `date +%s` or `date +%Y-%m-%d_%H-%M-%S` to generate unique file names for backups and logs

# Challenge 205
Filter Critical Log Entries from System Logs

Objective:
Write a Bash script that searches system log files for critical entries. This simulates a real-world scenario in which a system administrator needs to quickly find recent and potentially urgent log messages during a live incident or audit.

Requirements:
- Set a variable called LOG_FILE and default it to /var/log/syslog
- If /var/log/syslog does not exist, automatically fall back to /var/log/messages
- Search the selected log file for lines containing any of the following (case-insensitive):
  error, fail, panic, denied, segfault, crash
- Display only the last 20 matching lines using tail

Bonus:
- Accept a search term as a command-line argument ($1) and use it instead of the default list if provided
- Allow the user to specify how many matching lines to display (as a second argument)
- Output results to a log file in /tmp named logsearch_<timestamp>.log
- If no matches are found, print: No critical log entries found.

Example Run:
Searching for CRITICAL entries in /var/log/syslog...  
Jul 15 12:32:01 hostname kernel: memory access violation  
Jul 15 12:32:05 hostname sshd[1052]: failed password for invalid user

Tips:
- Use grep -Ei "pattern" to match multiple terms case-insensitively
- Use [ ! -f "$LOG_FILE" ] to check for file existence
- Use tail -n 20 to limit output to the most recent matching lines
- Use date +%Y-%m-%d_%H-%M-%S to generate unique log file names if logging output
