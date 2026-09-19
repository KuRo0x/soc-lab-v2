# Validation Scripts

## INC-006 lab C2 simulator

These two scripts create a controlled, private-network HTTP request/response exercise:

1. From the Kali VM, run `inc006-c2-server.py` on `172.16.0.11`.
2. From the monitored Win10 VM, run `inc006-agent.ps1` against `172.16.0.11`.
3. The agent sends a fixed number of beacons and accepts only the internal `status` task.

The scripts do not provide arbitrary command execution, persistence, evasion, credential access, or Internet callbacks. Use them only on the isolated lab network and stop the server after the test.

The repository/workstation machine is only for storing and transferring the scripts; do not run the controller or agent there.
