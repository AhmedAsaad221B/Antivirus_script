# Mini Antivirus Project

## Prerequisites

Before running the project, make sure you have:

- Ubuntu Linux.
- Bash shell.
- Cron installed and running.
- All the project scripts and the Makefile.
- The monitored directory `dir`.
- The quarantine directory `malicious_dir`.
- The whitelist file `whitelist.txt`, which stores the names of restored files so they can be skipped in future scans.

To install Cron if it is not already installed, run:

```bash
sudo apt update
sudo apt install cron
```

Enable and start the Cron service:

```bash
sudo systemctl enable --now cron
```

## Purpose

The project monitors changes in the directory `dir` and checks for malicious files. A file is considered malicious if it has a flagged extension or contains one of the flagged keywords.

### Flagged Extensions

- `.exe`
- `.bat`
- `.vbs`
- `.scr`
- `.ps1`

### Flagged Keywords

- `virus`
- `trojan`
- `malware`
- `worm`
- `ransomware`

The keyword search is case-insensitive.

## Project Files

### 1. `antivirusd.sh`

This script monitors the directory continuously.

At the beginning, it checks whether `directory-info.last` exists. If it does not exist, the script performs an initial scan and creates a snapshot of the directory.

After that, it follows these steps:

1. Waits for the specified interval.
2. Creates a new snapshot of the directory.
3. Compares the new snapshot with the previous one.
4. If a change is detected, scans the directory for malicious files.
5. Updates the previous snapshot.

When a malicious file is found, it is copied to `malicious_dir` and removed from the original directory.

### 2. `antivirus-cron.sh`

This script performs one scan of the monitored directory and then exits. Unlike `antivirusd.sh`, it does not run in an infinite loop. Cron is responsible for running it according to a schedule.

It checks the file extensions and contents using the same detection rules as the main antivirus script.

Files identified as malicious are copied to `malicious_dir` and removed from `dir`.

Files listed in `whitelist.txt` are skipped.

### 3. `restore.sh`

This script allows the user to review the quarantined files and choose what to do with them.

The available options are:

1. Restore the file to the monitored directory.
2. Permanently delete the file.
3. Go back without changing the file.

When a file is restored, its name is added to `whitelist.txt` so that future scans can skip it.

### 4. `Makefile`

The Makefile makes it easier to run the project commands, including starting the antivirus daemon and running the restore script. It also creates the quarantine directory when needed.

### 5. `whitelist.txt`

This file stores the names of files that have been restored and should be treated as safe by future scans.

### 6. `directory-info.last` and `directory-info.new`

These files store directory snapshots used by `antivirusd.sh` to detect changes.

### 7. `third-friday.sh`

This wrapper script checks whether the current day of the month falls between the 15th and 21st. It runs the Cron scanner only when the date matches the third Friday schedule.

## Running the Project

### Running the Antivirus Daemon

From the project directory, run:

```bash
make run
```

The daemon continues monitoring the directory until it is stopped.

### Running the Restore Script

Run:

```bash
make restore
```

Follow the instructions displayed in the terminal to restore or permanently delete quarantined files.

## Bonus 1: Cron Job

The Cron version performs a single scan whenever it is executed. It does not include the interactive restore loop because Cron jobs run automatically without user input.

### Configure the Cron Job to Run Every Minute at Second 23

Standard Cron scheduling works with minutes rather than seconds. To start the scan at approximately second 23 of every minute, use `sleep 23`.

Follow these steps:

1. Make sure Cron is installed and running.
2. Navigate to the project directory:

   ```bash
   cd ~/lab2
   ```

3. Make the scanner executable:

   ```bash
   chmod +x antivirus-cron.sh
   ```

4. Test the scanner manually:

   ```bash
   ./antivirus-cron.sh
   ```

5. Open the current user's Cron configuration:

   ```bash
   crontab -e
   ```

6. Add the following line, replacing `/home/ahmed/lab2` with the absolute path to the project directory if necessary:

   ```cron
   * * * * * sleep 23; /home/ahmed/lab2/antivirus-cron.sh >> /home/ahmed/lab2/antivirus-cron.log 2>&1
   ```

7. Save the file and exit the editor.

8. Check that the job was added:

   ```bash
   crontab -l
   ```

The five asterisks mean that the job runs every minute. The `sleep 23` command delays the scan by approximately 23 seconds.

The scan may start slightly later because the exact execution time depends on system scheduling.

The output and errors are saved in `antivirus-cron.log`.

### Cron Expression for the Third Friday of Every Month at 12:31 AM

The following expression runs every Friday at 12:31 AM:

```cron
31 0 * * 5
```

However, this runs every Friday, not just the third Friday.

To run the scanner only on the third Friday, use `third-friday.sh`.

First, make the wrapper executable:

```bash
chmod +x third-friday.sh
```

Then add this line to the user's Cron configuration:

```cron
31 0 * * 5 /home/ahmed/lab2/third-friday.sh
```

Replace the example path with the absolute path to the project directory.

Cron launches the wrapper every Friday at 12:31 AM. The wrapper checks the date and runs the scanner only when the day of the month is between the 15th and 21st, which identifies the third Friday.

The every-minute schedule and the third-Friday schedule are separate examples. Configure the schedule required for your use case.

### Managing Cron Jobs

To list the current user's Cron jobs:

```bash
crontab -l
```

To edit or remove a scheduled job:

```bash
crontab -e
```

To view the scanner's output:

```bash
cat ~/lab2/antivirus-cron.log
```

To remove a specific job, open `crontab -e` and delete its line.
