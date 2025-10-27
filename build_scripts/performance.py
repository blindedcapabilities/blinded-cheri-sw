import os
import re
import pandas as pd

# === Config ===
LOG_DIR = os.path.expanduser("~/cheri/blinded-cheri-sw/spec_log")

# === Regex pattern for parsing logs ===
log_pattern = re.compile(
    r"Mode:\s*(\d+), input:\s*(\d+).*?"
    r"work time\s*:\[(\d+)\]\s*"
    r"encrypt time:\[(\d+)\]\s*"
    r"total time\s*:\[(\d+)\]",
    re.DOTALL
)

# === Function to parse individual log file ===
def parse_log_file(file_path, filename):
    match = re.match(r"(chacha|sha2)_spec_(baseline|cheri|cheri_blinded)_(\d+)\.elf\.txt", filename)
    if not match:
        return None
    app, variant, input_size = match.groups()
    with open(file_path, "r") as f:
        content = f.read()
    log_match = log_pattern.search(content)
    if not log_match:
        return None
    mode, input_val, work, encrypt, total = log_match.groups()
    return {
        "app": app,
        "variant": variant,
        "input": int(input_size),
        "work_time": int(work),
        "encrypt_time": int(encrypt),
        "total_time": int(total)
    }

# === Collect and parse all log files ===
data = []
for filename in os.listdir(LOG_DIR):
    if filename.endswith(".txt"):
        entry = parse_log_file(os.path.join(LOG_DIR, filename), filename)
        if entry:
            data.append(entry)

# === Build DataFrame ===
df = pd.DataFrame(data)
df.sort_values(by=["app", "input", "variant"], inplace=True)

# === Compare to baseline ===
def compare_to_baseline(metric):
    baseline = df[df['variant'] == 'baseline'][["app", "input", metric]].rename(columns={metric: "baseline_" + metric})
    comparison = df[df['variant'] != 'baseline'][["app", "variant", "input", metric]]
    merged = comparison.merge(baseline, on=["app", "input"])
    merged[f"{metric}_diff_%"] = ((merged[metric] - merged[f"baseline_" + metric]) / merged[f"baseline_" + metric]) * 100
    return merged[["app", "variant", "input", metric, f"baseline_{metric}", f"{metric}_diff_%"]]

# === Compare cheri_blinded to cheri ===
def compare_blinded_to_cheri(metric):
    cheri = df[df['variant'] == 'cheri'][["app", "input", metric]].rename(columns={metric: "cheri_" + metric})
    blinded = df[df['variant'] == 'cheri_blinded'][["app", "input", metric]]
    merged = blinded.merge(cheri, on=["app", "input"])
    merged[f"{metric}_diff_%"] = ((merged[metric] - merged[f"cheri_" + metric]) / merged[f"cheri_" + metric]) * 100
    return merged[["app", "input", metric, f"cheri_{metric}", f"{metric}_diff_%"]]

# === Print all comparisons ===
for metric in ["work_time", "encrypt_time", "total_time"]:
    print(f"\n=== Comparison to Baseline for {metric} ===")
    print(compare_to_baseline(metric).to_string(index=False))

    print(f"\n--- Overhead: cheri_blinded vs cheri for {metric} ---")
    print(compare_blinded_to_cheri(metric).to_string(index=False))
