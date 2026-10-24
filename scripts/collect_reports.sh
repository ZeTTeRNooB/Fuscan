#!/usr/bin/env bash
set -euo pipefail

outroot="${1:-/home/genetics/data/Furscan/OUT}"
reportroot="${2:-/home/genetics/data/Furscan/REPORTS}"
mkdir -p "$reportroot/samples"

for sample_dir in "$outroot"/samples/*; do
  [[ -d "$sample_dir" ]] || continue
  sample="${sample_dir##*/}"
  dest="$reportroot/samples/$sample"
  mkdir -p "$dest"
  ln -sfn "$sample_dir" "$dest/fuscan_data"
  [[ -d "$outroot/pcgr/$sample" ]] && ln -sfn "$outroot/pcgr/$sample" "$dest/pcgr"
  [[ -f "$outroot/logs/$sample.log" ]] && ln -sfn "$outroot/logs/$sample.log" "$dest/run.log"
  for name in results_summary.filtered.txt results_summary.txt "${sample}.pcgr.fusions.tsv"; do
    [[ -f "$sample_dir/$name" ]] && ln -sfn "$sample_dir/$name" "$dest/$name"
  done
  for file in "$outroot/pcgr/$sample"/*.html "$outroot/pcgr/$sample"/*.pdf "$outroot/pcgr/$sample"/*.xlsx "$outroot/pcgr/$sample"/*.rna_fusion.tsv.gz "$outroot/pcgr/$sample"/*.fusion_ann.tsv.gz; do
    [[ -f "$file" ]] && ln -sfn "$file" "$dest/${file##*/}"
  done
done

printf 'sample\tfusion_events\tpcgr_html\tpcgr_pdf\tpcgr_xlsx\n' > "$reportroot/summary.tsv"
for dest in "$reportroot"/samples/*; do
  [[ -d "$dest" ]] || continue
  sample="${dest##*/}"
  n=0
  [[ -f "$dest/results_summary.filtered.txt" ]] && n="$(awk 'NR>1&&NF{n++} END{print n+0}' "$dest/results_summary.filtered.txt")"
  html=0; pdf=0; xlsx=0
  compgen -G "$dest/*.html" >/dev/null && html=1 || true
  compgen -G "$dest/*.pdf" >/dev/null && pdf=1 || true
  compgen -G "$dest/*.xlsx" >/dev/null && xlsx=1 || true
  printf '%s\t%s\t%s\t%s\t%s\n' "$sample" "$n" "$html" "$pdf" "$xlsx" >> "$reportroot/summary.tsv"
done

ln -sfn "$outroot/logs/monitor.log" "$reportroot/monitor.log"
ln -sfn "$outroot/sample_manifest.tsv" "$reportroot/sample_manifest.tsv"
