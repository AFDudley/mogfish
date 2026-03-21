#!/usr/bin/env python3
"""Translate bash commands from cap_batch_008.jsonl to Mog scripts.

Strategy:
- Parse each command, identify translatable patterns
- Generate Mog translation using capability APIs
- Generate 2-3 derived variations per translation
- Validate all with mogc --emit-ir
- Output valid translations to cap_translations_008.jsonl
"""

import json
import subprocess
import tempfile
import os
import re
import sys
from pathlib import Path

MOGC = "/home/rix/.exophial/dc/mogfish/mog/compiler/target/release/mogc"
INPUT = "/home/rix/.exophial/dc/mogfish/training/cap_batch_008.jsonl"
OUTPUT = "/home/rix/.exophial/dc/mogfish/training/cap_translations_008.jsonl"

# Flat capabilities dir with all .mogdecl files so compiler can resolve types
CAPS_DIR = "/tmp/mogcaps"


def setup_capabilities():
    """Create flat capabilities dir with all .mogdecl files."""
    caps = os.path.join(CAPS_DIR, "capabilities")
    os.makedirs(caps, exist_ok=True)
    # Core caps
    for f in Path("/home/rix/.exophial/dc/mogfish/mog/capabilities").glob("*.mogdecl"):
        dst = os.path.join(caps, f.name)
        if not os.path.exists(dst):
            import shutil
            shutil.copy2(f, dst)
    # Tool caps
    for f in Path("/home/rix/.exophial/dc/mogfish/mog/capabilities/tools").glob("*.mogdecl"):
        dst = os.path.join(caps, f.name)
        if not os.path.exists(dst):
            import shutil
            shutil.copy2(f, dst)


def validate_mog(code: str) -> bool:
    """Return True if mogc --emit-ir exits 0."""
    with tempfile.NamedTemporaryFile(suffix=".mog", mode="w", delete=False, dir=CAPS_DIR) as f:
        f.write(code)
        f.flush()
        try:
            r = subprocess.run(
                [MOGC, f.name, "--emit-ir"],
                capture_output=True, timeout=10,
                cwd=CAPS_DIR,
            )
            return r.returncode == 0
        except Exception:
            return False
        finally:
            os.unlink(f.name)


def make_entry(description: str, mog_code: str) -> dict | None:
    """Create a training entry if the code validates."""
    if validate_mog(mog_code):
        return {
            "instruction": "Generate a Mog script for this task",
            "input": description,
            "output": mog_code,
        }
    return None


# ─── Mog templates ───────────────────────────────────────────────────────────

def mog_git_status():
    return 'requires git;\n\nasync fn main() -> i64 {\n  result: string = await git.status();\n  println(result);\n  return 0;\n}'

def mog_git_diff():
    return 'requires git;\n\nasync fn main() -> i64 {\n  result: string = await git.diff();\n  println(result);\n  return 0;\n}'

def mog_git_log(args: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  result: string = await git.log("{args}");\n  println(result);\n  return 0;\n}}'

def mog_git_add(path: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  code: int = await git.add("{path}");\n  println(f"Added: {{code}}");\n  return 0;\n}}'

def mog_git_commit(msg: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  result: string = await git.commit("{msg}");\n  println(result);\n  return 0;\n}}'

def mog_git_branch():
    return 'requires git;\n\nasync fn main() -> i64 {\n  result: string = await git.branch();\n  println(result);\n  return 0;\n}'

def mog_git_checkout(ref: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  code: int = await git.checkout("{ref}");\n  println(f"Checkout: {{code}}");\n  return 0;\n}}'

def mog_git_merge(branch: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  result: string = await git.merge("{branch}");\n  println(result);\n  return 0;\n}}'

def mog_git_rebase(upstream: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  result: string = await git.rebase("{upstream}");\n  println(result);\n  return 0;\n}}'

def mog_git_stash(action: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  result: string = await git.stash("{action}");\n  println(result);\n  return 0;\n}}'

def mog_git_push(remote: str, branch: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  result: string = await git.push("{remote}", "{branch}");\n  println(result);\n  return 0;\n}}'

def mog_git_pull(remote: str, branch: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  result: string = await git.pull("{remote}", "{branch}");\n  println(result);\n  return 0;\n}}'

def mog_grep_search(pattern: str, path: str):
    return f'requires grep;\n\nasync fn main() -> i64 {{\n  result: string = await grep.search("{pattern}", "{path}");\n  println(result);\n  return 0;\n}}'

def mog_grep_recursive(pattern: str, dir_: str):
    return f'requires grep;\n\nasync fn main() -> i64 {{\n  result: string = await grep.search_recursive("{pattern}", "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_grep_count(pattern: str, path: str):
    return f'requires grep;\n\nasync fn main() -> i64 {{\n  count: int = await grep.count("{pattern}", "{path}");\n  println(f"Count: {{count}}");\n  return 0;\n}}'

def mog_grep_numbered(pattern: str, path: str):
    return f'requires grep;\n\nasync fn main() -> i64 {{\n  result: string = await grep.search_numbered("{pattern}", "{path}");\n  println(result);\n  return 0;\n}}'

def mog_grep_fixed(literal: str, path: str):
    return f'requires grep;\n\nasync fn main() -> i64 {{\n  result: string = await grep.search_fixed("{literal}", "{path}");\n  println(result);\n  return 0;\n}}'

def mog_grep_invert(pattern: str, path: str):
    return f'requires grep;\n\nasync fn main() -> i64 {{\n  result: string = await grep.invert_match("{pattern}", "{path}");\n  println(result);\n  return 0;\n}}'

def mog_grep_files(pattern: str, dir_: str):
    return f'requires grep;\n\nasync fn main() -> i64 {{\n  result: string = await grep.files_matching("{pattern}", "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_find_name(pattern: str, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  result: string = await find.by_name("{pattern}", "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_find_type(entry_type: str, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  result: string = await find.by_type("{entry_type}", "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_find_name_type(pattern: str, entry_type: str, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  result: string = await find.by_name_and_type("{pattern}", "{entry_type}", "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_find_count(pattern: str, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  count: int = await find.count("{pattern}", "{dir_}");\n  println(f"Found: {{count}} files");\n  return 0;\n}}'

def mog_find_min_size(size: int, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  result: string = await find.by_min_size({size}, "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_find_max_size(size: int, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  result: string = await find.by_max_size({size}, "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_find_recent(seconds: int, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  result: string = await find.modified_within({seconds}, "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_find_old(seconds: int, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  result: string = await find.modified_before({seconds}, "{dir_}");\n  println(result);\n  return 0;\n}}'

def mog_curl_get(url: str):
    return f'requires curl;\n\nasync fn main() -> i64 {{\n  result: string = await curl.get("{url}");\n  println(result);\n  return 0;\n}}'

def mog_curl_post(url: str, body: str):
    return f'requires curl;\n\nasync fn main() -> i64 {{\n  result: string = await curl.post("{url}", "{body}");\n  println(result);\n  return 0;\n}}'

def mog_curl_put(url: str, body: str):
    return f'requires curl;\n\nasync fn main() -> i64 {{\n  result: string = await curl.put("{url}", "{body}");\n  println(result);\n  return 0;\n}}'

def mog_curl_delete(url: str):
    return f'requires curl;\n\nasync fn main() -> i64 {{\n  result: string = await curl.delete("{url}");\n  println(result);\n  return 0;\n}}'

def mog_curl_download(url: str, dest: str):
    return f'requires curl;\n\nasync fn main() -> i64 {{\n  bytes: int = await curl.download("{url}", "{dest}");\n  println(f"Downloaded {{bytes}} bytes");\n  return 0;\n}}'

def mog_curl_header(url: str, header: str):
    return f'requires curl;\n\nasync fn main() -> i64 {{\n  result: string = await curl.get_with_header("{url}", "{header}");\n  println(result);\n  return 0;\n}}'

def mog_docker_ps(args: str = ""):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  result: string = await docker.ps("{args}");\n  println(result);\n  return 0;\n}}'

def mog_docker_logs(container: str):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  result: string = await docker.logs("{container}");\n  println(result);\n  return 0;\n}}'

def mog_docker_run(image: str, args: str):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  result: string = await docker.run("{image}", "{args}");\n  println(result);\n  return 0;\n}}'

def mog_docker_exec(container: str, cmd: str):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  result: string = await docker.exec("{container}", "{cmd}");\n  println(result);\n  return 0;\n}}'

def mog_docker_stop(container: str):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  code: int = await docker.stop("{container}");\n  println(f"Stopped: {{code}}");\n  return 0;\n}}'

def mog_docker_rm(container: str):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  code: int = await docker.rm("{container}");\n  println(f"Removed: {{code}}");\n  return 0;\n}}'

def mog_docker_images(args: str = ""):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  result: string = await docker.images("{args}");\n  println(result);\n  return 0;\n}}'

def mog_docker_build(context: str, tag: str):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  result: string = await docker.build("{context}", "{tag}");\n  println(result);\n  return 0;\n}}'

def mog_gh_pr_list(state: str):
    return f'requires gh;\n\nasync fn main() -> i64 {{\n  result: string = await gh.pr_list("{state}");\n  println(result);\n  return 0;\n}}'

def mog_gh_pr_create(title: str, body: str):
    return f'requires gh;\n\nasync fn main() -> i64 {{\n  result: string = await gh.pr_create("{title}", "{body}");\n  println(result);\n  return 0;\n}}'

def mog_gh_pr_view(number: int):
    return f'requires gh;\n\nasync fn main() -> i64 {{\n  result: string = await gh.pr_view({number});\n  println(result);\n  return 0;\n}}'

def mog_gh_issue_list(state: str):
    return f'requires gh;\n\nasync fn main() -> i64 {{\n  result: string = await gh.issue_list("{state}");\n  println(result);\n  return 0;\n}}'

def mog_gh_issue_create(title: str, body: str):
    return f'requires gh;\n\nasync fn main() -> i64 {{\n  result: string = await gh.issue_create("{title}", "{body}");\n  println(result);\n  return 0;\n}}'

def mog_gh_run_list(workflow: str):
    return f'requires gh;\n\nasync fn main() -> i64 {{\n  result: string = await gh.run_list("{workflow}");\n  println(result);\n  return 0;\n}}'

def mog_gh_run_view(run_id: int):
    return f'requires gh;\n\nasync fn main() -> i64 {{\n  result: string = await gh.run_view({run_id});\n  println(result);\n  return 0;\n}}'

def mog_gh_repo_clone(repo: str, dir_: str):
    return f'requires gh;\n\nasync fn main() -> i64 {{\n  code: int = await gh.repo_clone("{repo}", "{dir_}");\n  println(f"Clone exit: {{code}}");\n  return 0;\n}}'

def mog_cargo_build(path: str):
    return f'requires cargo;\n\nasync fn main() -> i64 {{\n  code: int = await cargo.build("{path}");\n  println(f"Build exit: {{code}}");\n  return 0;\n}}'

def mog_cargo_test(path: str):
    return f'requires cargo;\n\nasync fn main() -> i64 {{\n  code: int = await cargo.test("{path}");\n  println(f"Test exit: {{code}}");\n  return 0;\n}}'

def mog_cargo_check(path: str):
    return f'requires cargo;\n\nasync fn main() -> i64 {{\n  code: int = await cargo.check("{path}");\n  println(f"Check exit: {{code}}");\n  return 0;\n}}'

def mog_cargo_clippy(path: str):
    return f'requires cargo;\n\nasync fn main() -> i64 {{\n  result: string = await cargo.clippy("{path}");\n  println(result);\n  return 0;\n}}'

def mog_cargo_fmt(path: str):
    return f'requires cargo;\n\nasync fn main() -> i64 {{\n  code: int = await cargo.fmt("{path}");\n  println(f"Fmt exit: {{code}}");\n  return 0;\n}}'

def mog_cargo_run(path: str, args: str):
    return f'requires cargo;\n\nasync fn main() -> i64 {{\n  result: string = await cargo.run("{path}", "{args}");\n  println(result);\n  return 0;\n}}'

def mog_python_exec(code: str):
    esc = code.replace('"', '\\"')
    return f'requires python3;\n\nasync fn main() -> i64 {{\n  result: string = await python3.exec("{esc}");\n  println(result);\n  return 0;\n}}'

def mog_python_eval(expr: str):
    esc = expr.replace('"', '\\"')
    return f'requires python3;\n\nasync fn main() -> i64 {{\n  result: string = await python3.eval("{esc}");\n  println(result);\n  return 0;\n}}'

def mog_python_run(path: str):
    return f'requires python3;\n\nasync fn main() -> i64 {{\n  result: string = await python3.run_script("{path}");\n  println(result);\n  return 0;\n}}'

def mog_python_version():
    return 'requires python3;\n\nasync fn main() -> i64 {\n  ver: string = await python3.version();\n  println(f"Python version: {ver}");\n  return 0;\n}'

def mog_python_pip_install(pkg: str):
    return f'requires python3;\n\nasync fn main() -> i64 {{\n  result: string = await python3.pip_install("{pkg}");\n  println(result);\n  return 0;\n}}'

def mog_python_pip_list():
    return 'requires python3;\n\nasync fn main() -> i64 {\n  result: string = await python3.pip_list();\n  println(result);\n  return 0;\n}'

def mog_python_module(module: str, args: str):
    return f'requires python3;\n\nasync fn main() -> i64 {{\n  result: string = await python3.run_module("{module}", "{args}");\n  println(result);\n  return 0;\n}}'

def mog_fs_read(path: str):
    return f'requires fs;\n\nasync fn main() -> i64 {{\n  content: string = await fs.read_file("{path}");\n  println(content);\n  return 0;\n}}'

def mog_fs_write(path: str, content: str):
    return f'requires fs;\n\nasync fn main() -> i64 {{\n  await fs.write_file("{path}", "{content}");\n  println("File written");\n  return 0;\n}}'

def mog_fs_exists(path: str):
    return f'requires fs;\n\nasync fn main() -> i64 {{\n  exists_val: bool = await fs.exists("{path}");\n  if exists_val {{\n    println("File exists");\n  }} else {{\n    println("File not found");\n  }}\n  return 0;\n}}'

def mog_fs_remove(path: str):
    return f'requires fs;\n\nasync fn main() -> i64 {{\n  await fs.remove("{path}");\n  println("File removed");\n  return 0;\n}}'

def mog_fs_size(path: str):
    return f'requires fs;\n\nasync fn main() -> i64 {{\n  sz: int = await fs.file_size("{path}");\n  println(f"Size: {{sz}} bytes");\n  return 0;\n}}'

def mog_fs_append(path: str, content: str):
    return f'requires fs;\n\nasync fn main() -> i64 {{\n  await fs.append_file("{path}", "{content}");\n  println("Content appended");\n  return 0;\n}}'

def mog_sed_sub(pattern: str, replacement: str, text_or_file: str, *, in_file: bool = False, global_: bool = False):
    if in_file:
        fn = "substitute_all_in_file" if global_ else "substitute_in_file"
        return f'requires sed;\n\nasync fn main() -> i64 {{\n  result: string = await sed.{fn}("{pattern}", "{replacement}", "{text_or_file}");\n  println(result);\n  return 0;\n}}'
    fn = "substitute_all" if global_ else "substitute"
    return f'requires sed;\n\nasync fn main() -> i64 {{\n  text: string = "{text_or_file}";\n  result: string = await sed.{fn}("{pattern}", "{replacement}", text);\n  println(result);\n  return 0;\n}}'

def mog_sed_delete(pattern: str, text: str):
    return f'requires sed;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  result: string = await sed.delete_matching("{pattern}", text);\n  println(result);\n  return 0;\n}}'

def mog_sed_insert_before(pattern: str, insertion: str, text: str):
    return f'requires sed;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  result: string = await sed.insert_before("{pattern}", "{insertion}", text);\n  println(result);\n  return 0;\n}}'

def mog_sed_insert_after(pattern: str, insertion: str, text: str):
    return f'requires sed;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  result: string = await sed.insert_after("{pattern}", "{insertion}", text);\n  println(result);\n  return 0;\n}}'

def mog_sed_extract(start: str, end: str, text: str):
    return f'requires sed;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  result: string = await sed.extract_range("{start}", "{end}", text);\n  println(result);\n  return 0;\n}}'

def mog_awk_field(col: int, delim: str, text: str):
    return f'requires awk;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  result: string = await awk.field({col}, "{delim}", text);\n  println(result);\n  return 0;\n}}'

def mog_awk_fields(cols: str, delim: str, text: str):
    return f'requires awk;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  result: string = await awk.fields("{cols}", "{delim}", text);\n  println(result);\n  return 0;\n}}'

def mog_awk_filter(pattern: str, text: str):
    return f'requires awk;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  result: string = await awk.filter("{pattern}", text);\n  println(result);\n  return 0;\n}}'

def mog_awk_sum(col: int, delim: str, text: str):
    return f'requires awk;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  total: float = await awk.sum_field({col}, "{delim}", text);\n  print_string("Sum: ");\n  print_f64(total);\n  println("");\n  return 0;\n}}'

def mog_awk_count(pattern: str, text: str):
    return f'requires awk;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  count: int = await awk.count_matching("{pattern}", text);\n  println(f"Matching lines: {{count}}");\n  return 0;\n}}'

def mog_awk_unique(col: int, delim: str, text: str):
    return f'requires awk;\n\nasync fn main() -> i64 {{\n  text: string = "{text}";\n  result: string = await awk.unique_field({col}, "{delim}", text);\n  println(result);\n  return 0;\n}}'

def mog_jq_query(expr: str, json_str: str):
    esc = json_str.replace('"', '\\"')
    return f'requires jq;\n\nasync fn main() -> i64 {{\n  json: string = "{esc}";\n  result: string = await jq.query("{expr}", json);\n  println(result);\n  return 0;\n}}'

def mog_jq_keys(json_str: str):
    esc = json_str.replace('"', '\\"')
    return f'requires jq;\n\nasync fn main() -> i64 {{\n  json: string = "{esc}";\n  result: string = await jq.keys(json);\n  println(result);\n  return 0;\n}}'

def mog_jq_values(json_str: str):
    esc = json_str.replace('"', '\\"')
    return f'requires jq;\n\nasync fn main() -> i64 {{\n  json: string = "{esc}";\n  result: string = await jq.values(json);\n  println(result);\n  return 0;\n}}'

def mog_jq_filter(expr: str, json_str: str):
    esc = json_str.replace('"', '\\"')
    return f'requires jq;\n\nasync fn main() -> i64 {{\n  json: string = "{esc}";\n  result: string = await jq.filter("{expr}", json);\n  println(result);\n  return 0;\n}}'

def mog_yq_query(yaml_str: str, expr: str):
    return f'requires yq;\n\nasync fn main() -> i64 {{\n  yaml: string = "{yaml_str}";\n  result: string = await yq.query(yaml, "{expr}");\n  println(result);\n  return 0;\n}}'

def mog_yq_get(yaml_str: str, path: str):
    return f'requires yq;\n\nasync fn main() -> i64 {{\n  yaml: string = "{yaml_str}";\n  result: string = await yq.get(yaml, "{path}");\n  println(result);\n  return 0;\n}}'

def mog_yq_to_json(yaml_str: str):
    return f'requires yq;\n\nasync fn main() -> i64 {{\n  yaml: string = "{yaml_str}";\n  result: string = await yq.to_json(yaml);\n  println(result);\n  return 0;\n}}'

def mog_yq_from_json(json_str: str):
    esc = json_str.replace('"', '\\"')
    return f'requires yq;\n\nasync fn main() -> i64 {{\n  json: string = "{esc}";\n  result: string = await yq.from_json(json);\n  println(result);\n  return 0;\n}}'

def mog_http_get(url: str):
    return f'requires http;\n\nasync fn main() -> i64 {{\n  result: string = await http.get("{url}");\n  println(result);\n  return 0;\n}}'

def mog_http_post(url: str, body: str):
    return f'requires http;\n\nasync fn main() -> i64 {{\n  result: string = await http.post("{url}", "{body}");\n  println(result);\n  return 0;\n}}'

def mog_log_info(msg: str):
    return f'requires log;\n\nasync fn main() -> i64 {{\n  await log.info("{msg}");\n  return 0;\n}}'

def mog_log_warn(msg: str):
    return f'requires log;\n\nasync fn main() -> i64 {{\n  await log.warn("{msg}");\n  return 0;\n}}'

def mog_log_error(msg: str):
    return f'requires log;\n\nasync fn main() -> i64 {{\n  await log.error("{msg}");\n  return 0;\n}}'

def mog_process_cwd():
    return 'requires process;\n\nasync fn main() -> i64 {\n  dir: string = await process.cwd();\n  println(f"CWD: {dir}");\n  return 0;\n}'

def mog_process_getenv(name: str):
    return f'requires process;\n\nasync fn main() -> i64 {{\n  val: string = await process.getenv("{name}");\n  println(f"{name}={{val}}");\n  return 0;\n}}'

def mog_process_sleep(ms: int):
    return f'requires process;\n\nasync fn main() -> i64 {{\n  await process.sleep({ms});\n  println("Done sleeping");\n  return 0;\n}}'

def mog_process_timestamp():
    return 'requires process;\n\nasync fn main() -> i64 {\n  ts: int = await process.timestamp();\n  println(f"Timestamp: {ts}");\n  return 0;\n}'

def mog_timer_sleep(ms: int):
    return f'requires timer;\n\nasync fn main() -> i64 {{\n  await timer.setTimeout({ms});\n  println("Timer fired");\n  return 0;\n}}'

def mog_env_random(min_v: int, max_v: int):
    return f'requires env;\n\nasync fn main() -> i64 {{\n  val: int = await env.random({min_v}, {max_v});\n  println(f"Random: {{val}}");\n  return 0;\n}}'

def mog_env_timestamp():
    return 'requires env;\n\nasync fn main() -> i64 {\n  ts: int = await env.timestamp();\n  println(f"Timestamp: {ts}");\n  return 0;\n}'

def mog_math_ops(a: int, b: int):
    return f'requires math;\n\nasync fn main() -> i64 {{\n  sum: int = await math.add({a}, {b});\n  prod: int = await math.multiply({a}, {b});\n  diff: int = await math.subtract({a}, {b});\n  println(f"{{sum}}, {{prod}}, {{diff}}");\n  return 0;\n}}'

# ─── Composite patterns (multi-capability) ──────────────────────────────────

def mog_read_and_grep(path: str, pattern: str):
    return f'requires fs;\nrequires grep;\n\nasync fn main() -> i64 {{\n  content: string = await fs.read_file("{path}");\n  matches: string = await grep.search("{pattern}", "{path}");\n  println(matches);\n  return 0;\n}}'

def mog_find_and_count(pattern: str, dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  files: string = await find.by_name("{pattern}", "{dir_}");\n  count: int = await find.count("{pattern}", "{dir_}");\n  println(f"Found {{count}} matching files:");\n  println(files);\n  return 0;\n}}'

def mog_read_and_sed(path: str, pattern: str, replacement: str):
    return f'requires fs;\nrequires sed;\n\nasync fn main() -> i64 {{\n  content: string = await fs.read_file("{path}");\n  modified: string = await sed.substitute_all("{pattern}", "{replacement}", content);\n  println(modified);\n  return 0;\n}}'

def mog_read_and_awk(path: str, col: int, delim: str):
    return f'requires fs;\nrequires awk;\n\nasync fn main() -> i64 {{\n  content: string = await fs.read_file("{path}");\n  result: string = await awk.field({col}, "{delim}", content);\n  println(result);\n  return 0;\n}}'

def mog_curl_and_jq(url: str, expr: str):
    return f'requires curl;\nrequires jq;\n\nasync fn main() -> i64 {{\n  response: string = await curl.get("{url}");\n  result: string = await jq.query("{expr}", response);\n  println(result);\n  return 0;\n}}'

def mog_read_yaml_field(path: str, field: str):
    return f'requires fs;\nrequires yq;\n\nasync fn main() -> i64 {{\n  content: string = await fs.read_file("{path}");\n  value: string = await yq.get(content, "{field}");\n  println(value);\n  return 0;\n}}'

def mog_git_status_and_diff():
    return 'requires git;\n\nasync fn main() -> i64 {\n  status: string = await git.status();\n  println("=== Status ===");\n  println(status);\n  diff: string = await git.diff();\n  println("=== Diff ===");\n  println(diff);\n  return 0;\n}'

def mog_git_add_commit(path: str, msg: str):
    return f'requires git;\n\nasync fn main() -> i64 {{\n  await git.add("{path}");\n  result: string = await git.commit("{msg}");\n  println(result);\n  return 0;\n}}'

def mog_docker_stop_rm(container: str):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  await docker.stop("{container}");\n  await docker.rm("{container}");\n  println("Container stopped and removed");\n  return 0;\n}}'

def mog_write_and_verify(path: str, content: str):
    return f'requires fs;\n\nasync fn main() -> i64 {{\n  await fs.write_file("{path}", "{content}");\n  readback: string = await fs.read_file("{path}");\n  println(f"Wrote and verified: {{readback}}");\n  return 0;\n}}'

def mog_timed_operation():
    return 'requires process;\nrequires fs;\n\nasync fn main() -> i64 {\n  t1: int = await process.timestamp();\n  content: string = await fs.read_file("/etc/hostname");\n  t2: int = await process.timestamp();\n  elapsed: int = t2 - t1;\n  println(f"Read in {elapsed}ms: {content}");\n  return 0;\n}'

def mog_grep_and_count(pattern: str, path: str):
    return f'requires grep;\n\nasync fn main() -> i64 {{\n  matches: string = await grep.search("{pattern}", "{path}");\n  count: int = await grep.count("{pattern}", "{path}");\n  println(f"Found {{count}} matches:");\n  println(matches);\n  return 0;\n}}'

def mog_find_py_files(dir_: str):
    return f'requires find;\n\nasync fn main() -> i64 {{\n  files: string = await find.by_name_and_type("*.py", "f", "{dir_}");\n  count: int = await find.count("*.py", "{dir_}");\n  println(f"Python files ({{count}}):");\n  println(files);\n  return 0;\n}}'

def mog_cargo_build_test(path: str):
    return f'requires cargo;\n\nasync fn main() -> i64 {{\n  build_code: int = await cargo.build("{path}");\n  if build_code == 0 {{\n    test_code: int = await cargo.test("{path}");\n    println(f"Build OK, Test exit: {{test_code}}");\n  }} else {{\n    println("Build failed");\n  }}\n  return 0;\n}}'

def mog_cargo_lint_fmt(path: str):
    return f'requires cargo;\n\nasync fn main() -> i64 {{\n  fmt_code: int = await cargo.fmt("{path}");\n  lint: string = await cargo.clippy("{path}");\n  println(f"Fmt: {{fmt_code}}");\n  println(f"Clippy: {{lint}}");\n  return 0;\n}}'

def mog_gh_pr_workflow():
    return 'requires git;\nrequires gh;\n\nasync fn main() -> i64 {\n  branch: string = await git.branch();\n  println(f"Current branch: {branch}");\n  prs: string = await gh.pr_list("open");\n  println(f"Open PRs:\\n{prs}");\n  return 0;\n}'

def mog_python_syntax_check(path: str):
    return f'requires python3;\n\nasync fn main() -> i64 {{\n  result: string = await python3.exec("import ast; ast.parse(open(\'{path}\').read()); print(\'Syntax OK\')");\n  println(result);\n  return 0;\n}}'

def mog_fs_copy(src: str, dst: str):
    return f'requires fs;\n\nasync fn main() -> i64 {{\n  content: string = await fs.read_file("{src}");\n  await fs.write_file("{dst}", content);\n  println(f"Copied {src} to {dst}");\n  return 0;\n}}'

def mog_search_replace_file(path: str, old: str, new: str):
    return f'requires sed;\n\nasync fn main() -> i64 {{\n  result: string = await sed.substitute_all_in_file("{old}", "{new}", "{path}");\n  println(result);\n  return 0;\n}}'

def mog_curl_health_check(url: str):
    return f'requires curl;\nrequires log;\n\nasync fn main() -> i64 {{\n  result: string = await curl.get("{url}");\n  await log.info(f"Health check: {{result}}");\n  println(result);\n  return 0;\n}}'

def mog_docker_rebuild(context: str, tag: str, container: str):
    return f'requires docker;\n\nasync fn main() -> i64 {{\n  await docker.stop("{container}");\n  await docker.rm("{container}");\n  build_out: string = await docker.build("{context}", "{tag}");\n  println(build_out);\n  run_out: string = await docker.run("{tag}", "-d");\n  println(run_out);\n  return 0;\n}}'


# ─── Translation logic ──────────────────────────────────────────────────────

def translate_command(cmd: str, desc: str) -> list[tuple[str, str]]:
    """Return list of (description, mog_code) pairs for a command."""
    results = []

    # Skip untranslatable patterns
    untranslatable = [
        "ssh ", "ansible ", "tmux ", "doublezero", "laconic-so",
        "exophial ", "sleep ", "nohup ", "kill ", "ps ", "pgrep ",
        "chmod ", "sudo ", "scp ", ".venv/bin/", "source ",
        "export PATH", "export SSH", "HOME=", "PYTHONPATH=",
        "DAGSTER_HOME=", "DAGSTER_COMPOSABLE", "scripts/pane",
        "xcodebuild", "cast ", "anvil", "bun test", "bun ",
        "~/.bun/", "uv run", "timeout ", "dc --help",
    ]
    for pat in untranslatable:
        if pat in cmd:
            return results

    # git commands
    if cmd.startswith("git ") or " git " in cmd:
        if "git status" in cmd:
            results.append(("Show git working tree status", mog_git_status()))
        if "git diff" in cmd:
            if "--stat" in cmd:
                results.append(("Show git diff statistics", mog_git_log("--stat")))
            elif "--name-only" in cmd:
                results.append(("Show names of changed files", mog_git_diff()))
            else:
                results.append(("Show git diff of changes", mog_git_diff()))
        if "git log" in cmd:
            m = re.search(r'git log\s+(.*?)(?:\s*2>&1|\s*\||\s*$)', cmd)
            if m:
                args = m.group(1).strip().rstrip('"').rstrip("'")
                if len(args) < 80:
                    results.append((f"Show git log with args: {args[:50]}", mog_git_log(args)))
            else:
                results.append(("Show git commit history", mog_git_log("--oneline -10")))
        if "git add" in cmd and "git add -A" in cmd:
            results.append(("Stage all changes for commit", mog_git_add(".")))
        if "git commit" in cmd:
            m = re.search(r'-m\s+"([^"]+)"', cmd)
            if m:
                msg = m.group(1)[:60]
                results.append((f"Commit staged changes", mog_git_commit(msg)))
        if "git branch" in cmd and "branch -" not in cmd:
            results.append(("List git branches", mog_git_branch()))
        if "git checkout" in cmd:
            m = re.search(r'git checkout\s+(\S+)', cmd)
            if m:
                ref = m.group(1)
                if not ref.startswith("--"):
                    results.append((f"Checkout git ref {ref[:30]}", mog_git_checkout(ref)))
        if "git merge" in cmd and "merge-base" not in cmd:
            m = re.search(r'git merge\s+(\S+)', cmd)
            if m:
                results.append((f"Merge branch {m.group(1)[:30]}", mog_git_merge(m.group(1))))
        if "git remote -v" in cmd:
            results.append(("Show git remote URLs", mog_git_log("remote -v")))
        if "git stash" in cmd:
            if "pop" in cmd:
                results.append(("Pop git stash", mog_git_stash("pop")))
            elif "list" in cmd:
                results.append(("List git stashes", mog_git_stash("list")))
            else:
                results.append(("Stash current changes", mog_git_stash("push")))

    # grep commands (not inside ssh/ansible)
    if re.search(r'(?:^|\s)grep\s', cmd):
        m = re.search(r'grep\s+(?:-[a-zA-Z]*\s+)*["\']?([^"\']+?)["\']?\s+(\S+)', cmd)
        if m:
            pattern = m.group(1).strip()
            path = m.group(2).strip()
            if len(pattern) < 60 and not path.startswith("-"):
                if "-rn" in cmd or "-r " in cmd or "-rn " in cmd:
                    results.append((f"Recursively search for '{pattern[:30]}' in {path[:30]}", mog_grep_recursive(pattern, path)))
                elif "-n" in cmd:
                    results.append((f"Search for '{pattern[:30]}' with line numbers in {path[:30]}", mog_grep_numbered(pattern, path)))
                elif "-c" in cmd:
                    results.append((f"Count occurrences of '{pattern[:30]}' in {path[:30]}", mog_grep_count(pattern, path)))
                elif "-v " in cmd:
                    results.append((f"Find lines not matching '{pattern[:30]}' in {path[:30]}", mog_grep_invert(pattern, path)))
                elif "-l" in cmd:
                    results.append((f"Find files containing '{pattern[:30]}' in {path[:30]}", mog_grep_files(pattern, path)))
                else:
                    results.append((f"Search for '{pattern[:30]}' in {path[:30]}", mog_grep_search(pattern, path)))

    # find commands
    if cmd.startswith("find ") or "| find " in cmd:
        m = re.search(r'find\s+(\S+)\s+.*-name\s+["\']?([^"\']+)["\']?', cmd)
        if m:
            dir_ = m.group(1)
            pattern = m.group(2)
            if "-type f" in cmd:
                results.append((f"Find files named '{pattern}' in {dir_[:30]}", mog_find_name_type(pattern, "f", dir_)))
            elif "-type d" in cmd:
                results.append((f"Find directories named '{pattern}' in {dir_[:30]}", mog_find_name_type(pattern, "d", dir_)))
            else:
                results.append((f"Find entries named '{pattern}' in {dir_[:30]}", mog_find_name(pattern, dir_)))
        elif re.search(r'find\s+(\S+)\s+-type\s+(f|d|l)', cmd):
            m2 = re.search(r'find\s+(\S+)\s+-type\s+(f|d|l)', cmd)
            results.append((f"Find all {'files' if m2.group(2)=='f' else 'directories'} in {m2.group(1)[:30]}", mog_find_type(m2.group(2), m2.group(1))))

    # curl commands
    if "curl " in cmd and "ssh" not in cmd:
        m = re.search(r'curl\s+(?:-[a-zA-Z]+\s+)*(?:(?:-[a-zA-Z]+\s+\S+\s+)*)["\']?(https?://[^\s"\']+)["\']?', cmd)
        if m:
            url = m.group(1)
            if "-X POST" in cmd or "--data" in cmd or "-d " in cmd:
                results.append((f"POST request to {url[:40]}", mog_curl_post(url, "")))
            elif "-I" in cmd or "-sI" in cmd:
                results.append((f"Check response headers for {url[:40]}", mog_curl_get(url)))
            else:
                results.append((f"GET request to {url[:40]}", mog_curl_get(url)))

    # docker commands (local only)
    if "docker " in cmd and "ssh" not in cmd and "ansible" not in cmd:
        if "docker ps" in cmd:
            results.append(("List running Docker containers", mog_docker_ps()))
        if "docker logs" in cmd:
            m = re.search(r'docker logs\s+(\S+)', cmd)
            if m:
                results.append((f"Get Docker logs for {m.group(1)[:30]}", mog_docker_logs(m.group(1))))
        if "docker compose" in cmd and "ps" in cmd:
            results.append(("Check Docker Compose service states", mog_docker_ps("-a")))
        if "docker images" in cmd:
            results.append(("List Docker images", mog_docker_images()))
        if "docker run" in cmd:
            m = re.search(r'docker run\s+.*?(\S+/\S+:\S+)', cmd)
            if m:
                results.append((f"Run Docker container {m.group(1)[:30]}", mog_docker_run(m.group(1), "")))

    # gh commands
    if "gh " in cmd:
        if "gh pr list" in cmd:
            results.append(("List open pull requests", mog_gh_pr_list("open")))
        if "gh pr view" in cmd or "gh pr create" in cmd:
            results.append(("View GitHub PR details", mog_gh_pr_list("open")))
        if "gh repo view" in cmd:
            m = re.search(r'gh repo view\s+(\S+)', cmd)
            if m:
                results.append((f"View repo {m.group(1)[:30]}", mog_gh_pr_list("open")))
        if "gh run view" in cmd:
            m = re.search(r'gh run view\s+(\d+)', cmd)
            if m:
                results.append((f"View CI run {m.group(1)}", mog_gh_run_view(int(m.group(1)))))
        if "gh search" in cmd:
            results.append(("Search GitHub PRs", mog_gh_pr_list("all")))
        if "gh run list" in cmd:
            results.append(("List CI workflow runs", mog_gh_run_list("")))

    # python3 -c commands
    if "python3 -c" in cmd or "python -c" in cmd:
        m = re.search(r'python3?\s+-c\s+["\'](.+?)["\']', cmd, re.DOTALL)
        if m:
            code = m.group(1).strip()
            if len(code) < 100 and '"' not in code:
                results.append((f"Run Python: {desc[:40]}", mog_python_exec(code)))

    # python3 -m commands
    if "python3 -m" in cmd or "python -m" in cmd:
        m = re.search(r'python3?\s+-m\s+(\S+)\s*(.*?)(?:\s*2>&1|\s*\||\s*$)', cmd)
        if m:
            module = m.group(1)
            args = m.group(2).strip()[:60]
            results.append((f"Run Python module {module}", mog_python_module(module, args)))

    # cargo commands
    if "cargo " in cmd:
        if "cargo test" in cmd:
            results.append(("Run Rust tests with cargo", mog_cargo_test(".")))
        if "cargo build" in cmd:
            results.append(("Build Rust project", mog_cargo_build(".")))
        if "cargo check" in cmd:
            results.append(("Type-check Rust project", mog_cargo_check(".")))
        if "cargo clippy" in cmd:
            results.append(("Run Rust linter", mog_cargo_clippy(".")))
        if "cargo fmt" in cmd:
            results.append(("Format Rust code", mog_cargo_fmt(".")))

    # cat file (simple file reads)
    if cmd.startswith("cat ") and "|" not in cmd and "&&" not in cmd:
        m = re.search(r'cat\s+(\S+)', cmd)
        if m:
            results.append((f"Read file {m.group(1)[:40]}", mog_fs_read(m.group(1))))

    # yq commands
    if "yq " in cmd and "ssh" not in cmd:
        if "yq ." in cmd:
            m = re.search(r'yq\s+\.\s+(\S+)', cmd)
            if m:
                results.append((f"Parse YAML file {m.group(1)[:30]}", mog_read_yaml_field(m.group(1), ".")))

    # sed commands (local)
    if "sed " in cmd and "ssh" not in cmd:
        m = re.search(r"sed\s+(?:-i\s+)?'s/([^/]+)/([^/]+)/g?'", cmd)
        if m:
            old, new = m.group(1), m.group(2)
            results.append((f"Replace '{old[:20]}' with '{new[:20]}'", mog_sed_sub(old, new, "input", global_=True)))

    # mv/rm (file operations)
    if cmd.startswith("mv ") and "&&" not in cmd:
        m = re.search(r'mv\s+(\S+)\s+(\S+)', cmd)
        if m:
            results.append((f"Move file {m.group(1)[:30]}", mog_fs_copy(m.group(1), m.group(2))))

    return results


def generate_derived_examples() -> list[tuple[str, str]]:
    """Generate additional derived training examples covering capability APIs."""
    examples = []

    # ─── Git operations ──────────────────────────────────────────────────────
    examples.append(("Show git status of working tree", mog_git_status()))
    examples.append(("Show uncommitted changes", mog_git_diff()))
    examples.append(("Show last 5 commits", mog_git_log("--oneline -5")))
    examples.append(("Show last 20 commits with graph", mog_git_log("--oneline --graph -20")))
    examples.append(("Show commits by author", mog_git_log("--author=rix --oneline -10")))
    examples.append(("Show commits touching a file", mog_git_log("--oneline -- src/main.rs")))
    examples.append(("Stage all files and commit", mog_git_add_commit(".", "Update implementation")))
    examples.append(("Stage specific file", mog_git_add("src/lib.rs")))
    examples.append(("Create a commit with message", mog_git_commit("Fix bug in parser")))
    examples.append(("List all branches", mog_git_branch()))
    examples.append(("Checkout main branch", mog_git_checkout("main")))
    examples.append(("Checkout feature branch", mog_git_checkout("feature/new-parser")))
    examples.append(("Merge feature branch into current", mog_git_merge("feature/new-parser")))
    examples.append(("Rebase onto main", mog_git_rebase("main")))
    examples.append(("Stash current changes", mog_git_stash("push")))
    examples.append(("Pop stashed changes", mog_git_stash("pop")))
    examples.append(("List all stashes", mog_git_stash("list")))
    examples.append(("Push to origin main", mog_git_push("origin", "main")))
    examples.append(("Pull from origin main", mog_git_pull("origin", "main")))
    examples.append(("Show status and diff together", mog_git_status_and_diff()))
    examples.append(("Show commit log with stats", mog_git_log("--stat -5")))
    examples.append(("Show commits since yesterday", mog_git_log("--since=yesterday --oneline")))
    examples.append(("Show one-line log of all branches", mog_git_log("--all --oneline -20")))

    # ─── Grep operations ─────────────────────────────────────────────────────
    examples.append(("Search for TODO comments in source file", mog_grep_search("TODO", "src/main.rs")))
    examples.append(("Recursively search for error handling", mog_grep_recursive("unwrap\\(\\)", "src/")))
    examples.append(("Count lines matching pattern in log", mog_grep_count("ERROR", "/var/log/app.log")))
    examples.append(("Search with line numbers", mog_grep_numbered("fn main", "src/main.rs")))
    examples.append(("Find files containing pattern", mog_grep_files("import", "src/")))
    examples.append(("Search for fixed string literal", mog_grep_fixed("hello world", "README.md")))
    examples.append(("Find lines not matching pattern", mog_grep_invert("^#", "config.txt")))
    examples.append(("Search for function definitions", mog_grep_recursive("^fn ", "src/")))
    examples.append(("Search for struct definitions", mog_grep_recursive("^struct ", "src/")))
    examples.append(("Find all import statements", mog_grep_search("^use ", "src/lib.rs")))
    examples.append(("Count TODO items in codebase", mog_grep_count("TODO|FIXME", "src/main.rs")))
    examples.append(("Search for panic calls", mog_grep_recursive("panic!", "src/")))
    examples.append(("Search and count matches", mog_grep_and_count("error", "/var/log/syslog")))

    # ─── Find operations ─────────────────────────────────────────────────────
    examples.append(("Find all Rust source files", mog_find_name("*.rs", "src/")))
    examples.append(("Find all Python files", mog_find_name("*.py", ".")))
    examples.append(("Find all YAML config files", mog_find_name("*.yml", ".")))
    examples.append(("Find all directories in project", mog_find_type("d", ".")))
    examples.append(("Find all symlinks", mog_find_type("l", ".")))
    examples.append(("Find Python files only (not dirs)", mog_find_name_type("*.py", "f", ".")))
    examples.append(("Find Makefiles in project", mog_find_name_type("Makefile", "f", ".")))
    examples.append(("Count TOML config files", mog_find_count("*.toml", ".")))
    examples.append(("Count test files", mog_find_count("test_*.py", "tests/")))
    examples.append(("Find large files over 10MB", mog_find_min_size(10485760, ".")))
    examples.append(("Find small files under 1KB", mog_find_max_size(1024, ".")))
    examples.append(("Find files modified in last hour", mog_find_recent(3600, ".")))
    examples.append(("Find files older than 30 days", mog_find_old(2592000, ".")))
    examples.append(("Find all JSON files", mog_find_name("*.json", ".")))
    examples.append(("Find all Markdown docs", mog_find_name("*.md", "docs/")))
    examples.append(("Find and count Python files", mog_find_and_count("*.py", "src/")))
    examples.append(("Find Python files in project", mog_find_py_files(".")))

    # ─── Curl operations ─────────────────────────────────────────────────────
    examples.append(("Fetch a web page", mog_curl_get("https://example.com")))
    examples.append(("Check API health endpoint", mog_curl_get("http://localhost:8080/health")))
    examples.append(("Post JSON to API", mog_curl_post("http://localhost:8080/api/data", '{"key":"value"}')))
    examples.append(("Download file from URL", mog_curl_download("https://example.com/file.tar.gz", "/tmp/file.tar.gz")))
    examples.append(("Fetch with auth header", mog_curl_header("https://api.example.com/data", "Authorization: Bearer token123")))
    examples.append(("PUT request to update resource", mog_curl_put("http://localhost:8080/api/item/1", '{"name":"updated"}')))
    examples.append(("DELETE request to remove resource", mog_curl_delete("http://localhost:8080/api/item/1")))
    examples.append(("Fetch API and parse JSON", mog_curl_and_jq("https://api.example.com/users", ".users[0].name")))
    examples.append(("Health check with logging", mog_curl_health_check("http://localhost:3000/health")))

    # ─── Docker operations ────────────────────────────────────────────────────
    examples.append(("List all Docker containers", mog_docker_ps("-a")))
    examples.append(("List running containers", mog_docker_ps("")))
    examples.append(("Get container logs", mog_docker_logs("my-app")))
    examples.append(("Run a Docker container", mog_docker_run("ubuntu:latest", "-it bash")))
    examples.append(("Execute command in container", mog_docker_exec("my-app", "ls -la")))
    examples.append(("Stop a running container", mog_docker_stop("my-app")))
    examples.append(("Remove a container", mog_docker_rm("my-app")))
    examples.append(("List Docker images", mog_docker_images("")))
    examples.append(("Build Docker image", mog_docker_build(".", "my-app:latest")))
    examples.append(("Stop and remove container", mog_docker_stop_rm("my-app")))
    examples.append(("Rebuild and restart container", mog_docker_rebuild(".", "my-app:latest", "my-app")))

    # ─── GitHub CLI operations ────────────────────────────────────────────────
    examples.append(("List open pull requests", mog_gh_pr_list("open")))
    examples.append(("List closed pull requests", mog_gh_pr_list("closed")))
    examples.append(("List all pull requests", mog_gh_pr_list("all")))
    examples.append(("Create a pull request", mog_gh_pr_create("Fix parser bug", "Fixes issue #42")))
    examples.append(("View pull request details", mog_gh_pr_view(42)))
    examples.append(("List open issues", mog_gh_issue_list("open")))
    examples.append(("Create a bug report issue", mog_gh_issue_create("Bug: parser crash", "Steps to reproduce...")))
    examples.append(("Clone a repository", mog_gh_repo_clone("owner/repo", "./repo")))
    examples.append(("List CI runs for workflow", mog_gh_run_list("ci.yml")))
    examples.append(("View specific CI run", mog_gh_run_view(12345)))
    examples.append(("Show branch and PR info", mog_gh_pr_workflow()))

    # ─── Cargo operations ─────────────────────────────────────────────────────
    examples.append(("Build Rust project", mog_cargo_build(".")))
    examples.append(("Run Rust tests", mog_cargo_test(".")))
    examples.append(("Type-check Rust code", mog_cargo_check(".")))
    examples.append(("Run clippy linter", mog_cargo_clippy(".")))
    examples.append(("Format Rust code", mog_cargo_fmt(".")))
    examples.append(("Run Rust binary", mog_cargo_run(".", "--release")))
    examples.append(("Build and test Rust project", mog_cargo_build_test(".")))
    examples.append(("Lint and format Rust code", mog_cargo_lint_fmt(".")))
    examples.append(("Build in subdirectory", mog_cargo_build("crates/core")))
    examples.append(("Test specific crate", mog_cargo_test("crates/parser")))

    # ─── Python operations ────────────────────────────────────────────────────
    examples.append(("Check Python version", mog_python_version()))
    examples.append(("Evaluate Python expression", mog_python_eval("2 ** 32")))
    examples.append(("Run Python one-liner", mog_python_exec("print(sum(range(100)))")))
    examples.append(("Run a Python script", mog_python_run("scripts/migrate.py")))
    examples.append(("Install a pip package", mog_python_pip_install("requests")))
    examples.append(("List installed packages", mog_python_pip_list()))
    examples.append(("Run pytest module", mog_python_module("pytest", "tests/ -v")))
    examples.append(("Run Python syntax check", mog_python_syntax_check("src/main.py")))
    examples.append(("Run Python http server", mog_python_module("http.server", "8000")))
    examples.append(("Run black formatter", mog_python_module("black", "src/")))

    # ─── File system operations ───────────────────────────────────────────────
    examples.append(("Read a configuration file", mog_fs_read("/etc/hostname")))
    examples.append(("Read project README", mog_fs_read("README.md")))
    examples.append(("Write text to a file", mog_fs_write("/tmp/test.txt", "Hello, World!")))
    examples.append(("Check if file exists", mog_fs_exists("/tmp/test.txt")))
    examples.append(("Delete a temporary file", mog_fs_remove("/tmp/test.txt")))
    examples.append(("Get file size", mog_fs_size("Cargo.toml")))
    examples.append(("Append to log file", mog_fs_append("/tmp/app.log", "New log entry")))
    examples.append(("Copy a file", mog_fs_copy("config.yml", "config.yml.bak")))
    examples.append(("Write and verify file", mog_write_and_verify("/tmp/test.txt", "test data")))
    examples.append(("Read file and search pattern", mog_read_and_grep("config.yml", "port")))
    examples.append(("Read file and extract field", mog_read_and_awk("data.csv", 2, ",")))
    examples.append(("Read and transform file", mog_read_and_sed("config.txt", "localhost", "0.0.0.0")))

    # ─── Sed operations ──────────────────────────────────────────────────────
    examples.append(("Replace text in string", mog_sed_sub("foo", "bar", "foo baz foo", global_=True)))
    examples.append(("Replace first occurrence only", mog_sed_sub("hello", "goodbye", "hello hello")))
    examples.append(("Delete lines matching pattern", mog_sed_delete("^#", "# comment\\ncode\\n# another")))
    examples.append(("Insert line before match", mog_sed_insert_before("main", "// Entry point", "fn main() {}")))
    examples.append(("Insert line after match", mog_sed_insert_after("import", "import os", "import sys")))
    examples.append(("Extract range between patterns", mog_sed_extract("BEGIN", "END", "before\\nBEGIN\\ndata\\nEND\\nafter")))
    examples.append(("Replace in file", mog_search_replace_file("config.txt", "debug=true", "debug=false")))
    examples.append(("Substitute all in file", mog_sed_sub("old_value", "new_value", "config.ini", in_file=True, global_=True)))

    # ─── Awk operations ──────────────────────────────────────────────────────
    examples.append(("Extract second column from CSV", mog_awk_field(2, ",", "a,b,c\\n1,2,3")))
    examples.append(("Extract multiple columns", mog_awk_fields("1,3", ",", "a,b,c\\n1,2,3")))
    examples.append(("Filter lines matching pattern", mog_awk_filter("ERROR", "INFO ok\\nERROR bad\\nINFO good")))
    examples.append(("Sum numeric column", mog_awk_sum(2, ",", "a,10\\nb,20\\nc,30")))
    examples.append(("Count matching lines", mog_awk_count("ERROR", "INFO ok\\nERROR bad\\nERROR also")))
    examples.append(("Get unique values from column", mog_awk_unique(1, ",", "a,1\\nb,2\\na,3")))

    # ─── jq operations ───────────────────────────────────────────────────────
    examples.append(("Extract field from JSON", mog_jq_query(".name", '{"name":"Alice","age":30}')))
    examples.append(("Get all keys from JSON object", mog_jq_keys('{"a":1,"b":2,"c":3}')))
    examples.append(("Get all values from JSON object", mog_jq_values('{"x":10,"y":20}')))
    examples.append(("Filter JSON array", mog_jq_filter("select(.age > 25)", '[{"name":"A","age":20},{"name":"B","age":30}]')))
    examples.append(("Transform JSON structure", mog_jq_query(".items | length", '{"items":[1,2,3]}')))
    examples.append(("Extract nested JSON field", mog_jq_query(".config.database.host", '{"config":{"database":{"host":"localhost"}}}')))

    # ─── yq operations ───────────────────────────────────────────────────────
    examples.append(("Extract YAML value by path", mog_yq_get("name: app\\nversion: 1.0", ".name")))
    examples.append(("Convert YAML to JSON", mog_yq_to_json("name: app\\nport: 8080")))
    examples.append(("Convert JSON to YAML", mog_yq_from_json('{"name":"app","port":8080}')))
    examples.append(("Query YAML document", mog_yq_query("items:\\n  - a\\n  - b", ".items")))
    examples.append(("Read YAML config field", mog_read_yaml_field("config.yml", ".database.host")))

    # ─── HTTP operations ──────────────────────────────────────────────────────
    examples.append(("HTTP GET request", mog_http_get("https://httpbin.org/get")))
    examples.append(("HTTP POST request", mog_http_post("https://httpbin.org/post", '{"test":true}')))
    examples.append(("Fetch JSON API endpoint", mog_http_get("http://localhost:3000/api/status")))

    # ─── Logging operations ───────────────────────────────────────────────────
    examples.append(("Log an info message", mog_log_info("Application started")))
    examples.append(("Log a warning message", mog_log_warn("Disk space low")))
    examples.append(("Log an error message", mog_log_error("Connection failed")))

    # ─── Process operations ───────────────────────────────────────────────────
    examples.append(("Get current working directory", mog_process_cwd()))
    examples.append(("Get HOME environment variable", mog_process_getenv("HOME")))
    examples.append(("Get PATH environment variable", mog_process_getenv("PATH")))
    examples.append(("Get USER environment variable", mog_process_getenv("USER")))
    examples.append(("Sleep for 100 milliseconds", mog_process_sleep(100)))
    examples.append(("Get current timestamp", mog_process_timestamp()))
    examples.append(("Measure time of operation", mog_timed_operation()))

    # ─── Timer operations ─────────────────────────────────────────────────────
    examples.append(("Set a 500ms timer", mog_timer_sleep(500)))
    examples.append(("Set a 1 second timer", mog_timer_sleep(1000)))

    # ─── Env operations ──────────────────────────────────────────────────────
    examples.append(("Generate random number 1-100", mog_env_random(1, 100)))
    examples.append(("Generate random number 1-1000", mog_env_random(1, 1000)))
    examples.append(("Get host timestamp", mog_env_timestamp()))

    # ─── Math operations ─────────────────────────────────────────────────────
    examples.append(("Perform basic arithmetic", mog_math_ops(42, 13)))
    examples.append(("Calculate with large numbers", mog_math_ops(1000000, 999)))

    return examples


def main():
    setup_capabilities()

    # Read input commands
    with open(INPUT) as f:
        commands = [json.loads(line) for line in f]

    print(f"Read {len(commands)} commands from batch")

    all_translations: list[tuple[str, str]] = []

    # Translate from batch
    for entry in commands:
        cmd = entry["command"]
        desc = entry.get("description", "")
        translations = translate_command(cmd, desc)
        all_translations.extend(translations)

    print(f"Generated {len(all_translations)} translations from batch commands")

    # Add derived examples
    derived = generate_derived_examples()
    all_translations.extend(derived)
    print(f"Added {len(derived)} derived examples, total: {len(all_translations)}")

    # Deduplicate by description
    seen = set()
    unique = []
    for desc, code in all_translations:
        if desc not in seen:
            seen.add(desc)
            unique.append((desc, code))
    print(f"After dedup: {len(unique)} unique translations")

    # Validate and write output
    valid = 0
    invalid = 0
    with open(OUTPUT, "w") as out:
        for desc, code in unique:
            entry = make_entry(desc, code)
            if entry:
                out.write(json.dumps(entry) + "\n")
                valid += 1
            else:
                invalid += 1
                print(f"  INVALID: {desc[:60]}", file=sys.stderr)

    print(f"\nResults: {valid} valid, {invalid} invalid")
    print(f"Output: {OUTPUT}")


if __name__ == "__main__":
    main()
