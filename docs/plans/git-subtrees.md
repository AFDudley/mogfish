# Plan: Add fish-shell and mog as git subtrees in mogfish/

## Context

mogfish is a new repo (`/home/rix/.exophial/dc/mogfish/`) with no commits yet — just two untracked markdown files. We need to bring in the two upstream repos (fish-shell and mog) as subtrees so they live inside mogfish as subdirectories with full history, allowing future upstream pulls.

## Steps

1. **Initial commit** — stage and commit the existing `mogfish.md` and `mogfish-training.md` so we have a root commit (subtree add requires an existing commit history).

2. **Add fish-shell as subtree**
   ```
   git subtree add --prefix=fish https://github.com/fish-shell/fish-shell.git main --squash
   ```
   - `--squash` collapses upstream history into a single merge commit (keeps mogfish log clean)
   - Prefix: `fish/`

3. **Add mog as subtree**
   ```
   git subtree add --prefix=mog https://github.com/voltropy/mog.git main --squash
   ```
   - Prefix: `mog/`
   - Branch may be `main` or `master` — will check at execution time

## Files modified
- `mogfish/fish/` — fish-shell subtree
- `mogfish/mog/` — mog subtree

## Verification
- `git log --oneline` shows initial commit + two subtree merge commits
- `ls fish/` contains fish-shell source
- `ls mog/` contains mog source
- `git subtree pull --prefix=fish ...` works for future upstream sync
