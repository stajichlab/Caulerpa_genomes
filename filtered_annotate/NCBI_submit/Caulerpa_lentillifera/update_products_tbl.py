#!/usr/bin/env python3
"""
update_products_tbl.py — Transfer product names from a source .tbl to a target .tbl.

Products in mRNA and CDS features are updated by matching transcript_id qualifiers
between the source and target files.  A report is written for genes whose genomic
span differs between source and target.

Usage:
    python update_products_tbl.py \\
        --source source.tbl --target target.tbl \\
        -o output.tbl [--report name_change.report.txt]
"""

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------

@dataclass
class GeneInfo:
    locus_tag: str
    scaffold: str
    start: int
    end: int
    strand: str

    @property
    def length(self):
        return self.end - self.start + 1


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_FEAT_RE = re.compile(r"^[<>]?\d+\t[<>]?\d+\t(\S+)")
_COORD_RE = re.compile(r"^[<>]?\d+\t[<>]?\d+$")
_QUAL_RE  = re.compile(r"^\t{3}(\S+)\t(.*)")


def _normalize_tid(raw: str) -> str:
    """gnl|ncbi|LOCUS-T1_mrna  →  LOCUS-T1"""
    raw = re.sub(r"^gnl\|[^|]+\|", "", raw)
    raw = re.sub(r"_mrna$", "", raw, flags=re.IGNORECASE)
    return raw


def _feature_type(line: str) -> Optional[str]:
    m = _FEAT_RE.match(line)
    return m.group(1) if m else None


def _is_coord_continuation(line: str) -> bool:
    return bool(_COORD_RE.match(line))


def _qual(line: str) -> Optional[tuple[str, str]]:
    m = _QUAL_RE.match(line)
    return (m.group(1), m.group(2)) if m else None


# ---------------------------------------------------------------------------
# Source tbl parsing
# ---------------------------------------------------------------------------

def parse_source(tbl_path: str) -> tuple[dict, dict]:
    """
    Parse the source tbl and return:
        src_products  : {tid_norm → product_str}
        src_gene_info : {tid_norm → GeneInfo}
    """
    src_products: dict[str, str] = {}
    src_gene_info: dict[str, GeneInfo] = {}

    scaffold = ""
    gene_start = gene_end = 0
    gene_strand = "+"
    locus_tag = ""
    feature = ""        # current feature type
    cur_tid = ""        # transcript_id seen so far in this mRNA feature
    cur_product = ""    # product seen so far in this mRNA feature

    def _flush_mrna():
        nonlocal cur_tid, cur_product
        if cur_tid:
            tid = _normalize_tid(cur_tid)
            if cur_product:
                src_products[tid] = cur_product
            src_gene_info[tid] = GeneInfo(
                locus_tag=locus_tag,
                scaffold=scaffold,
                start=gene_start,
                end=gene_end,
                strand=gene_strand,
            )
        cur_tid = ""
        cur_product = ""

    with open(tbl_path) as fh:
        for raw in fh:
            line = raw.rstrip("\n")

            # Scaffold header
            if line.startswith(">Feature "):
                _flush_mrna()
                scaffold = line.split(None, 1)[1].split()[0]
                feature = ""
                continue

            # Feature line
            ft = _feature_type(line)
            if ft is not None:
                if feature == "mRNA":
                    _flush_mrna()
                feature = ft
                if ft == "gene":
                    # parse gene coordinates
                    parts = line.split("\t")
                    a, b = int(parts[0].lstrip("<>")), int(parts[1].lstrip("<>"))
                    gene_start, gene_end = min(a, b), max(a, b)
                    gene_strand = "+" if a <= b else "-"
                    locus_tag = ""
                continue

            # Coordinate continuation (multi-exon)
            if _is_coord_continuation(line):
                continue

            # Qualifier
            q = _qual(line)
            if q is None:
                continue
            key, val = q

            if feature == "gene" and key == "locus_tag":
                locus_tag = val
            elif feature == "mRNA":
                if key == "product":
                    cur_product = val
                elif key == "transcript_id":
                    cur_tid = val

    _flush_mrna()
    return src_products, src_gene_info


# ---------------------------------------------------------------------------
# Target tbl processing (with product update + gene info collection)
# ---------------------------------------------------------------------------

def _extract_tid_and_update_product(
    block: list[str],
    src_products: dict,
) -> tuple[list[str], str]:
    """
    Given a list of lines belonging to a single mRNA or CDS feature block:
    - Find the transcript_id qualifier.
    - If its normalised form is in src_products, replace the product qualifier.
    Returns (updated_lines, tid_norm).
    """
    tid_norm = ""
    product_new = ""

    # First pass: find transcript_id
    for line in block:
        q = _qual(line)
        if q and q[0] == "transcript_id":
            tid_norm = _normalize_tid(q[1])
            product_new = src_products.get(tid_norm, "")
            break

    if not product_new:
        return block, tid_norm

    # Second pass: replace product qualifier
    updated = []
    for line in block:
        q = _qual(line)
        if q and q[0] == "product":
            # preserve original indentation (always \t\t\t)
            updated.append(f"\t\t\tproduct\t{product_new}")
        else:
            updated.append(line)
    return updated, tid_norm


def process_target(
    tbl_path: str,
    src_products: dict,
    output_path: str,
) -> dict:
    """
    Stream through the target tbl, updating product qualifiers in mRNA and CDS
    features when a matching transcript_id is found in src_products.

    Returns tgt_gene_info: {tid_norm → GeneInfo}
    """
    BUFFER_FEATURES = {"mRNA", "CDS"}

    tgt_gene_info: dict[str, GeneInfo] = {}

    scaffold = ""
    gene_start = gene_end = 0
    gene_strand = "+"
    locus_tag = ""
    feature = ""
    buffer: list[str] = []          # buffered lines for current mRNA/CDS block
    updated_count = 0
    tid_to_locus: dict[str, str] = {}   # tid_norm → locus_tag (target)

    out = open(output_path, "w") if output_path != "-" else sys.stdout

    def _flush_buffer():
        nonlocal updated_count
        if not buffer:
            return
        updated, tid_norm = _extract_tid_and_update_product(buffer, src_products)
        if tid_norm and feature == "mRNA":
            tgt_gene_info[tid_norm] = GeneInfo(
                locus_tag=locus_tag,
                scaffold=scaffold,
                start=gene_start,
                end=gene_end,
                strand=gene_strand,
            )
            tid_to_locus[tid_norm] = locus_tag
            if tid_norm in src_products:
                updated_count += 1
        for ln in updated:
            out.write(ln + "\n")

    with open(tbl_path) as fh:
        for raw in fh:
            line = raw.rstrip("\n")

            # Scaffold header
            if line.startswith(">Feature "):
                _flush_buffer()
                buffer = []
                feature = ""
                scaffold = line.split(None, 1)[1].split()[0]
                out.write(line + "\n")
                continue

            # Detect feature line
            ft = _feature_type(line)
            if ft is not None:
                if feature in BUFFER_FEATURES:
                    _flush_buffer()
                    buffer = []
                elif buffer:
                    for ln in buffer:
                        out.write(ln + "\n")
                    buffer = []

                feature = ft

                if ft == "gene":
                    parts = line.split("\t")
                    a, b = int(parts[0].lstrip("<>")), int(parts[1].lstrip("<>"))
                    gene_start, gene_end = min(a, b), max(a, b)
                    gene_strand = "+" if a <= b else "-"
                    locus_tag = ""

                if ft in BUFFER_FEATURES:
                    buffer.append(line)
                else:
                    out.write(line + "\n")
                continue

            # Coordinate continuation
            if _is_coord_continuation(line):
                if feature in BUFFER_FEATURES:
                    buffer.append(line)
                else:
                    out.write(line + "\n")
                continue

            # Qualifier
            if feature in BUFFER_FEATURES:
                buffer.append(line)
            else:
                # gene or other feature qualifiers — emit directly
                q = _qual(line)
                if q and q[0] == "locus_tag":
                    locus_tag = q[1]
                out.write(line + "\n")

    # flush final buffer
    _flush_buffer()

    if output_path != "-":
        out.close()

    print(f"  {updated_count} transcripts updated with new product name", file=sys.stderr)
    return tgt_gene_info


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

def write_report(
    src_gene_info: dict,
    tgt_gene_info: dict,
    report_path: str,
) -> None:
    """
    Write a tab-delimited report of transcripts present in both source and target
    where the gene genomic span length differs.
    """
    columns = [
        "transcript_id",
        "src_locus_tag", "src_scaffold", "src_start", "src_end", "src_length",
        "tgt_locus_tag", "tgt_scaffold", "tgt_start", "tgt_end", "tgt_length",
        "length_diff",
    ]

    rows = []
    for tid, src in src_gene_info.items():
        tgt = tgt_gene_info.get(tid)
        if tgt is None:
            continue
        if src.length != tgt.length:
            rows.append([
                tid,
                src.locus_tag, src.scaffold, src.start, src.end, src.length,
                tgt.locus_tag, tgt.scaffold, tgt.start, tgt.end, tgt.length,
                tgt.length - src.length,
            ])

    rows.sort(key=lambda r: (r[2], r[3]))  # sort by scaffold, start

    with open(report_path, "w") as fh:
        fh.write("\t".join(columns) + "\n")
        for r in rows:
            fh.write("\t".join(str(x) for x in r) + "\n")

    # Summary to stderr
    total_matched = sum(1 for tid in src_gene_info if tid in tgt_gene_info)
    print(f"  {total_matched} transcripts matched between source and target", file=sys.stderr)
    print(f"  {len(rows)} transcripts have different gene lengths", file=sys.stderr)
    print(f"  Report written: {report_path}", file=sys.stderr)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args():
    parser = argparse.ArgumentParser(
        description=(
            "Transfer product names from a source NCBI .tbl to a target .tbl "
            "by matching transcript_id qualifiers."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python update_products_tbl.py \\
      --source annotated.tbl --target new_models.tbl \\
      -o updated.tbl --report length_changes.txt
""",
    )
    parser.add_argument("--source", required=True,
                        metavar="FILE",
                        help="Source .tbl file (product names are read from here)")
    parser.add_argument("--target", required=True,
                        metavar="FILE",
                        help="Target .tbl file (product names are updated here)")
    parser.add_argument("-o", "--output", required=True,
                        metavar="FILE",
                        help="Output .tbl file ('-' for stdout)")
    parser.add_argument("--report", default="name_change.report.txt",
                        metavar="FILE",
                        help="Report file for genes with different lengths (default: name_change.report.txt)")
    return parser.parse_args()


def main():
    args = parse_args()

    # Sanity checks
    for p in (args.source, args.target):
        if not Path(p).exists():
            print(f"ERROR: file not found: {p}", file=sys.stderr)
            sys.exit(1)

    if args.output != "-" and Path(args.output).resolve() == Path(args.target).resolve():
        print("ERROR: --output must differ from --target to avoid overwriting.", file=sys.stderr)
        sys.exit(1)

    # 1. Parse source tbl
    print(f"Parsing source: {args.source}", file=sys.stderr)
    src_products, src_gene_info = parse_source(args.source)
    print(f"  {len(src_products)} transcripts with products in source", file=sys.stderr)

    # 2. Process target tbl (update products, collect gene info)
    print(f"Processing target: {args.target}", file=sys.stderr)
    tgt_gene_info = process_target(args.target, src_products, args.output)

    # 3. Write length-difference report
    print(f"Writing report: {args.report}", file=sys.stderr)
    write_report(src_gene_info, tgt_gene_info, args.report)


if __name__ == "__main__":
    main()
