#!/usr/bin/env bash
# Download the newest successful main-branch iOS build, then refresh the local IPA source.
set -euo pipefail

repo="1368129224/immich-z"
workflow="build-ios.yml"
artifact="immich-z-ios-ipa-unsigned"
ipa_name="ImmichZ-unsigned.ipa"
ipa_dir="/mnt/ssd/temp/ipa"
updater="/home/zooter/docker-config/livecontainer-ipa-source/update-source.py"

for tool in gh python3; do
  command -v "$tool" >/dev/null || { echo "Missing command: $tool" >&2; exit 1; }
done
[[ -f "$updater" ]] || { echo "Missing updater: $updater" >&2; exit 1; }

# Pick the newest *successful* main run; a failed or running run has no usable IPA.
run_id="$(gh run list -R "$repo" -w "$workflow" -b main -s success -L 1 --json databaseId \
  --jq '.[0].databaseId // empty')"
[[ -n "$run_id" ]] || { echo "No successful main-branch run found for $workflow" >&2; exit 1; }

mkdir -p "$ipa_dir"
staging="$(mktemp -d "$ipa_dir/.download.XXXXXXXX")"
trap 'rm -rf -- "$staging"' EXIT

echo "Downloading run $run_id ($artifact)..."
if ! gh run download "$run_id" -R "$repo" -n "$artifact" -D "$staging" 2>/dev/null; then
  echo "Artifact download failed (possibly hit storage quota), falling back to release $ipa_name..."
  gh release download latest-build -R "$repo" -p "$ipa_name" -D "$staging" --clobber
fi
ipa="$staging/$ipa_name"
[[ -s "$ipa" ]] || { echo "Could not obtain $ipa_name from artifact or release" >&2; exit 1; }

# An Actions artifact is an outer ZIP; gh extracts it. Never rename that ZIP to .ipa.
python3 - "$ipa" <<'PY'
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    if archive.testzip() is not None or not any(
        name.startswith('Payload/') and name.endswith('.app/Info.plist')
        for name in archive.namelist()
    ):
        raise SystemExit('Downloaded file is not a valid Device IPA')
PY

# Staging is on the same filesystem, so replacement is atomic. Preserve other IPA files.
mv -f -- "$ipa" "$ipa_dir/$ipa_name"
python3 "$updater" --ipa-dir "$ipa_dir"
echo "Updated $ipa_dir/$ipa_name from Actions run $run_id"
