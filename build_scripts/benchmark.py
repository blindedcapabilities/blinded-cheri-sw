import subprocess
import time
import threading
import os
from datetime import datetime

# === Configuration ===
OPENOCD_CMD = [
    "/home/merve/opt/bin/openocd",
    "-f", "/home/merve/BESSPIN-GFE/testing/targets/vcu110_p3.cfg"
]
GDB_BIN = "/home/merve/opt/riscv/bin/riscv64-unknown-elf-gdb"
ELF_DIR = os.path.expanduser("~/cheri/blinded-cheri-sw/spec_bench")
LOG_DIR = os.path.expanduser("~/cheri/blinded-cheri-sw/spec_log")
SOCAT_DEVICE = "/dev/ttyUSB2"

# Create log directory if it doesn't exist
os.makedirs(LOG_DIR, exist_ok=True)

# Get all ELF files
elf_files = sorted([f for f in os.listdir(ELF_DIR) if f.endswith(".elf")])

# === Function to read serial and return socat process + thread ===
def read_serial_and_return_process(log_path, elf_name):
    socat_cmd = ["socat", "-", f"{SOCAT_DEVICE},raw,echo=0"]
    logfile = open(log_path, "w", buffering=1)
    logfile.write(f"# Log for ELF: {elf_name}\n# Timestamp: {datetime.now()}\n\n")

    socat_proc = subprocess.Popen(
        socat_cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        bufsize=0
    )

    def serial_reader():
        try:
            while True:
                char = socat_proc.stdout.read(1)
                if not char:
                    break
                logfile.write(char)
                logfile.flush()
        except Exception:
            pass
        finally:
            logfile.close()

    serial_thread = threading.Thread(target=serial_reader)
    serial_thread.start()

    return socat_proc, serial_thread

# === Run each ELF file ===
for elf_name in elf_files:
    elf_path = os.path.join(ELF_DIR, elf_name)
    log_path = os.path.join(LOG_DIR, f"{elf_name}.txt")

    print(f"\n=== Running {elf_name} ===")
    print(f"Logging serial output to {log_path}")

    # Step 1: Start OpenOCD
    openocd_proc = subprocess.Popen(
        OPENOCD_CMD,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )
    time.sleep(3)

    # Step 2: Start GDB
    gdb_cmd = [GDB_BIN, elf_path]
    gdb_proc = subprocess.Popen(
        gdb_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )

    def send_gdb_commands():
        def monitor_gdb():
            breakpoint_hit = False
            for line in gdb_proc.stdout:
                print(f"[GDB] {line.strip()}")
                if "Breakpoint" in line and "_init" in line and not breakpoint_hit:
                    breakpoint_hit = True
                    print("[GDB AUTO] Hit breakpoint at _init — sending 'continue'")
                    gdb_proc.stdin.write("continue\n")
                    gdb_proc.stdin.flush()
                elif "SIGTRAP" in line:
                    print("[GDB AUTO] SIGTRAP detected — sending 'quit'")
                    gdb_proc.stdin.write("quit\n")
                    gdb_proc.stdin.flush()
                    break

        commands = [
            "target remote localhost:3333\n",
            "disconnect\n",
            "target remote localhost:3333\n",
            "break _init\n",
            "load\n"
        ]
        
        for cmd in commands:
            print(f"[GDB CMD] {cmd.strip()}")
            gdb_proc.stdin.write(cmd)
            gdb_proc.stdin.flush()
            time.sleep(2)

            if cmd.strip() == "load":
                print("[GDB] Pausing after 'load' to allow target stabilization...")
                time.sleep(5)  # <- Pause here

        # Now continue
        gdb_proc.stdin.write("continue\n")
        gdb_proc.stdin.flush()
        print("[GDB CMD] continue")

        monitor_gdb()



    gdb_thread = threading.Thread(target=send_gdb_commands)
    gdb_thread.start()

    # Step 4: Start socat
    socat_proc, serial_thread = read_serial_and_return_process(log_path, elf_name)

    # Optional: Print OpenOCD output
    def print_output(proc, name):
        for line in proc.stdout:
            print(f"[{name}] {line.strip()}")

    openocd_output_thread = threading.Thread(target=print_output, args=(openocd_proc, "OpenOCD"), daemon=True)
    openocd_output_thread.start()
    time.sleep(4)

    try:
        gdb_proc.wait(timeout=30)
        print("GDB exited within 30 seconds.")
    except subprocess.TimeoutExpired:
        print("GDB did not exit within 30 seconds. Terminating...")
        gdb_proc.terminate()
        try:
            gdb_proc.wait(timeout=5)
            print("GDB terminated cleanly.")
        except subprocess.TimeoutExpired:
            gdb_proc.kill()
            print("GDB was force-killed.")

    # Step 6: Cleanup socat
    socat_proc.terminate()
    try:
        socat_proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        socat_proc.kill()
    serial_thread.join()

    # Step 7: Cleanup OpenOCD
    print(f"Terminating OpenOCD for {elf_name}...")
    openocd_proc.terminate()
    try:
        openocd_proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        openocd_proc.kill()

    print(f"✅ Finished {elf_name}")
    print("-" * 60)

print("✅ All ELF files processed.")
