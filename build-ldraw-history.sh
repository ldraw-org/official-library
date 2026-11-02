#!/usr/bin/env bash

# This file was generated with machine assistance is marked with CCO. See LICENSE for more details

# build-ldraw-history.sh SRC_DIR REPO_DIR
set -euo pipefail

SRC=${1:?usage: $0 SRC_DIR REPO_DIR}
REPO=${2:?usage: $0 SRC_DIR REPO_DIR}
BUILD=$(dirname "$(realpath -m "$REPO")")/ldraw-build   # mapping + logs live outside the repo
DATES="$BUILD/dates.tsv"                                # optional: "<release>\t<ISO date>" overrides
RESET_RELEASE="lcad0801"                                # this release replaces the whole tree
RESET_PRESERVE=(models)                                 # top-level dirs the reset must not clear
LIBDIR="$REPO/ldraw"                                    # library lives here; repo-level files stay outside

SZ=$(command -v 7zz || command -v 7z || true)
[[ -n $SZ ]] || { echo "need 7zip (apt install 7zip)"; exit 1; }

fail() { echo "FAIL: $*" >&2; exit 1; }

# Normalized form of a path relative to the library root.
# This is the single source of truth: the collision pre-check, mapping.tsv
# and the renaming step all use it.
#  - every directory component is lowercased
#  - the file name is lowercased only if the file lives under p/ or parts/,
#    or is one of the named files below
norm_rel() {
  awk -F/ '{
    n=NF; top=tolower($1); f=tolower($NF)
    norm = (top=="p" || top=="parts") && n>1
    if (n==1 && (f=="mklist-c.zip" || f=="mklist.exe" || f=="parts.lst")) norm=1
    if (n==2 && top=="models" && (f=="car.dat" || f=="pyramid.dat")) norm=1
    out=""
    for (i=1;i<=n;i++) { c=$i; if (i<n || norm) c=tolower(c); out=out (i>1?"/":"") c }
    # top-level files with a fixed, mixed-case canonical spelling
    if (n==1 && f=="ldconfig.ldr") out="LDConfig.ldr"
    if (n==1 && f=="ldcfgalt.ldr") out="LDCfgalt.ldr"
    print out
  }'
}

mkdir -p "$REPO" "$BUILD"
: > "$BUILD/mapping.tsv"
: > "$BUILD/collisions.log"

# ---- repo init -------------------------------------------------------------
if [[ ! -d $REPO/.git ]]; then
  git -C "$REPO" init -q
  git -C "$REPO" config core.ignorecase false
  git -C "$REPO" config core.autocrlf false
  printf '* -text\n' > "$REPO/.gitattributes"
  git -C "$REPO" add .gitattributes
  git -C "$REPO" commit -q -m "Repository setup"
fi

# ---- ordered release list ---------------------------------------------------
# fields: key, priority (0=zip, 1=exe), name, path
# key = year*100 + release; ldraw027 is the base and sorts first.
# YY >= 90 is 19YY. Sorting on priority makes zip win over exe for the same name.
list=$(
  shopt -s nullglob nocaseglob
  for f in "$SRC"/ldraw027.zip "$SRC"/lcad[0-9][0-9][0-9][0-9].{zip,exe}; do
    b=$(basename "${f,,}"); name=${b%.*}; ext=${b##*.}
    if [[ $name == ldraw027 ]]; then
      key=0
    else
      yy=${name:4:2}; rr=${name:6:2}
      year=$(( 10#$yy >= 90 ? 1900 + 10#$yy : 2000 + 10#$yy ))
      key=$(( year * 100 + 10#$rr ))
    fi
    pri=1; [[ $ext == zip ]] && pri=0
    printf '%s\t%s\t%s\t%s\n' "$key" "$pri" "$name" "$f"
  done | sort -t $'\t' -n -k1,1 -k2,2
)

prev=""; prev_key=""; reset_seen=0
while IFS=$'\t' read -r key pri name file; do
  # same release as an earlier (higher-priority) entry: zip already won
  if [[ $name == "$prev" ]]; then
    echo "note: $name also available as $(basename "$file"); using zip"
    continue
  fi
  prev=$name

  # gap check within a year (e.g. 0003 -> 0005)
  if [[ -n $prev_key && $name != ldraw027 ]] && (( key / 100 == prev_key / 100 )) \
       && (( key - prev_key != 1 )); then
    echo "WARN: gap before $name (previous key $prev_key)" >&2
  fi
  prev_key=$key

  # tag: YYYY-RR (the base release keeps its own name)
  if [[ $name == ldraw027 ]]; then
    tag=$name
  else
    tag=$(printf '%04d-%02d' $(( key / 100 )) $(( key % 100 )))
  fi

  echo "=== $name -> $tag ($(basename "$file"))"

  # 1. integrity test (ZIP and ARJ both carry CRC32s)
  "$SZ" t "$file" >/dev/null || fail "integrity test for $file"

  # 2. collisions after normalization, checked on the archive listing before
  #    extracting. Files only; the optional leading ldraw/ is stripped first.
  dups=$("$SZ" l -slt "$file" \
         | awk '/^Path = /{p=substr($0,8)} /^Folder = /{ if ($3=="-") print p }' \
         | tr '\\' '/' \
         | sed -E 's#^[Ll][Dd][Rr][Aa][Ww]/##' \
         | norm_rel | sort | uniq -d)
  if [[ -n $dups ]]; then
    { echo "$name:"; echo "$dups"; } >> "$BUILD/collisions.log"
    fail "path collisions after normalization in $file (see collisions.log)"
  fi

  # 3. extract to scratch
  tmp=$(mktemp -d "$BUILD/x.XXXXXX")
  "$SZ" x -y -o"$tmp" "$file" >/dev/null

  # 4. find the library root: a top-level ldraw dir (any case) if present,
  #    otherwise treat the archive's top level as the ldraw directory itself
  shopt -s nullglob dotglob
  top=("$tmp"/*)
  shopt -u nullglob dotglob
  root=""; extras=()
  for t in "${top[@]}"; do
    if [[ -d $t && ${t##*/} == [Ll][Dd][Rr][Aa][Ww] ]]; then root=$t
    else extras+=("${t##*/}"); fi
  done
  if [[ -n $root ]]; then
    (( ${#extras[@]} == 0 )) || fail "$name has ldraw/ plus other top-level entries: ${extras[*]}"
    layout="ldraw/"
  else
    root=$tmp
    layout="flat (no ldraw/ dir)"
  fi
  echo "    layout: $layout"

  # 5a. record original -> normalized mapping for every file whose path changes
  while IFS= read -r -d '' f; do
    rel=${f#"$root"/}
    nrel=$(printf '%s\n' "$rel" | norm_rel)
    if [[ $rel != "$nrel" ]]; then
      printf '%s\t%s\t%s\n' "$name" "$rel" "$nrel" >> "$BUILD/mapping.tsv"
    fi
  done < <(find "$root" -type f -print0)

  # 5b. lowercase every directory name, deepest first
  while IFS= read -r -d '' d; do
    base=${d##*/}; lower=${base,,}
    if [[ $base != "$lower" ]]; then
      dest="${d%/*}/$lower"
      [[ ! -e $dest ]] || fail "directory rename collision $d -> $dest"
      mv -- "$d" "$dest"
    fi
  done < <(find "$root" -mindepth 1 -depth -type d -print0)

  # 5c. files: rename anything that differs from its normalized path
  while IFS= read -r -d '' f; do
    rel=${f#"$root"/}
    nrel=$(printf '%s\n' "$rel" | norm_rel)
    if [[ $rel != "$nrel" ]]; then
      dest="$root/$nrel"
      [[ ! -e $dest ]] || fail "file rename collision $rel -> $nrel"
      mv -- "$f" "$dest"
    fi
  done < <(find "$root" -type f -print0)

  # 6. reset release: clear the library directory (keeping the preserved
  #    subdirectories) so anything else not in this archive disappears.
  #    Repo-level files (README.md, .gitignore, .gitattributes) are never touched.
  allow_delete=0
  if [[ $name == "$RESET_RELEASE" ]]; then
    echo "    RESET release: clearing $LIBDIR (preserving: ${RESET_PRESERVE[*]})"
    if [[ -d $LIBDIR ]]; then
      keep=()
      for k in "${RESET_PRESERVE[@]}"; do keep+=( ! -name "$k" ); done
      find "$LIBDIR" -mindepth 1 -maxdepth 1 "${keep[@]}" -exec rm -rf -- {} +
    fi
    allow_delete=1
    reset_seen=1
  fi
  
  # 7. overlay onto the library directory: adds new files, overwrites changed ones
  mkdir -p "$LIBDIR"
  cp -a "$root"/. "$LIBDIR"/

  # 8. stage only the library, then enforce the "nothing is ever deleted" rule (except on reset)
  git -C "$REPO" add -A -- ldraw
  deleted=$(git -C "$REPO" diff --cached --name-only --diff-filter=D)
  if (( allow_delete == 0 )) && [[ -n $deleted ]]; then
    fail "$name would delete files: $deleted"
  fi
  
  # 9. the repo must never hold two paths that differ only by case;
  #    report the actual spellings, not the lowercased form
  clash=$(git -C "$REPO" ls-files | awk '{ k=tolower($0); c[k]++; a[k]=a[k] "\n  " $0 }
                                          END { for (k in c) if (c[k]>1) print a[k] }')
  [[ -z $clash ]] || fail "$name leaves case-variant paths in the repo: $clash"

  # 10. commit date: override file, else newest mtime in the archive
  date=""
  [[ -f $DATES ]] && date=$(awk -F'\t' -v n="$name" '$1==n{print $2}' "$DATES")
  if [[ -z $date ]]; then
    epoch=$(find "$root" -type f -printf '%T@\n' | sort -n | tail -1 | cut -d. -f1)
    date="@$epoch +0000"
  fi

  if git -C "$REPO" diff --cached --quiet; then
    echo "WARN: $name produced no changes" >&2
  else
    added=$(git -C "$REPO" diff --cached --name-only --diff-filter=A | wc -l)
    modified=$(git -C "$REPO" diff --cached --name-only --diff-filter=M | wc -l)
    removed=$(git -C "$REPO" diff --cached --name-only --diff-filter=D | wc -l)
    GIT_AUTHOR_DATE=$date GIT_COMMITTER_DATE=$date \
      git -C "$REPO" commit -q -m "Release $tag" \
        -m "Source: $(basename "$file"). Layout: $layout. Added: $added, modified: $modified, deleted: $removed."
    git -C "$REPO" tag "$tag"
  fi

  rm -rf "$tmp"
done <<< "$list"

(( reset_seen == 1 )) || echo "WARN: reset release $RESET_RELEASE was never processed" >&2
echo "Done. Mapping: $BUILD/mapping.tsv"
