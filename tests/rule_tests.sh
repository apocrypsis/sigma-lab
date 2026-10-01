set -e # Exit immediately if a syntax check fails

echo ""
echo "=== Validating and linting Sigma syntax ==="

# Disable colourised outputs because it makes things messy
# when the terminal doesn't support colours.
NO_COLOR=1 rsigma rule lint ./rules/

echo ""
echo "=== Running logic validation ==="

# Initialise an array to hold all dynamic expectations flags.
expectations_args=()
# Loop through the test folder to find every expectation file.
while IFS= read -r file; do
  expectations_args+=("--expectations" "$file")
done < <(find tests/corpus/ -name "*.expect.yml")

# Do the same for logs, i.e., collect only real log files for the corpus engine.
corpus_args=()
while IFS= read -r log_file; do
  corpus_args+=("--corpus" "$log_file")
done < <(find tests/corpus/ -type f \( -name "*.json" -o -name "*.jsonl" -o -name "*.ndjson" \))

# Execute rsigma natively, passing the array expansions.
rsigma rule backtest \
  --rules ./rules/ \
  "${corpus_args[@]}" \
  --unexpected fail \
  "${expectations_args[@]}"

echo "SUCCESS: All rules validated"
exit 0
