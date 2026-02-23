#!/usr/bin/env python3
"""
The Asset Curator - Repository Organizer Script

This script organizes a chaotic repository of trading bots and learning materials
into a clean structure:
1. /Bots_XML/ -> Subfolders A-Z and 0-9 for XML bots.
2. /Materiais_de_Estudo/ -> PDFs, videos, and other study materials.
3. /Projetos_Isolados/ -> Everything else (MetaTrader files, zips, code, etc.).

Features:
- Deduplication using SHA256 hashing.
- Flattening of directory structures.
- Conflict resolution (renaming duplicates with timestamps).
- Automatic index generation.
- README update.
- Ignores specific system files and documentation folders.
"""

import os
import shutil
import hashlib
import re
from datetime import datetime
from pathlib import Path

# --- Configuration ---
ROOT_DIR = os.getcwd()

# Target Directories
DIR_BOTS = "Bots_XML"
DIR_STUDY = "Materiais_de_Estudo"
DIR_ISOLATED = "Projetos_Isolados"

# Extensions
EXT_XML = {'.xml'}
EXT_STUDY = {'.pdf', '.epub', '.docx', '.xlsx', '.xlsm', '.txt', '.rtf', '.pptx', '.mp4', '.mkv', '.avi', '.mov', '.doc', '.ppt'}

# Ignored Paths (Files and Directories to skip)
IGNORED_NAMES = {
    '.git', '.github', '.gitignore', 'README.md', 'LICENSE', 'AGENTS.md',
    'organize_repo.py', 'index.md', 'requirements.txt', '.DS_Store'
}

# Potential documentation folders to ignore (add more if known)
IGNORED_DIRS = {'docs', 'documentation', 'doc', 'manuals'}

# --- Helper Functions ---

def get_file_hash(filepath):
    """Calculates the SHA256 hash of a file."""
    hasher = hashlib.sha256()
    try:
        with open(filepath, 'rb') as f:
            while chunk := f.read(8192):
                hasher.update(chunk)
        return hasher.hexdigest()
    except Exception as e:
        print(f"Error hashing {filepath}: {e}")
        return None

def is_ignored(path):
    """Checks if a file or directory should be ignored."""
    parts = Path(path).parts
    # Check if any part of the path is in the ignored list
    for part in parts:
        if part in IGNORED_NAMES or part in IGNORED_DIRS:
            return True
    return False

def get_target_category(filename):
    """
    Determines the target category and subfolder for a file.
    Returns (category_folder, subfolder)
    """
    name, ext = os.path.splitext(filename)
    ext = ext.lower()

    # XML Bots
    if ext in EXT_XML:
        # Determine first character
        clean_name = re.sub(r'^[^a-zA-Z0-9]+', '', name) # Strip leading non-alphanumeric chars for sorting?
        # Actually, user said "based on their filename". Let's stick to the actual filename first char.
        # But if it starts with space or symbol, maybe fallback to next char?
        # Let's just use the first alphanumeric char found, or fallback to 'Projetos_Isolados' if none.

        first_char = ''
        for char in name:
            if char.isalnum():
                first_char = char
                break

        if not first_char:
            # No alphanumeric char found, go to Isolated
            return DIR_ISOLATED, None

        if first_char.isdigit():
            return DIR_BOTS, "0-9"
        else:
            return DIR_BOTS, first_char.upper()

    # Study Materials
    if ext in EXT_STUDY:
        return DIR_STUDY, None

    # Everything else
    return DIR_ISOLATED, None

def unique_path(directory, filename):
    """
    Generates a unique path for a file in the destination directory.
    If a file with the same name exists, appends a timestamp.
    """
    base, ext = os.path.splitext(filename)
    counter = 1
    new_filename = filename
    dest_path = os.path.join(directory, new_filename)

    while os.path.exists(dest_path):
        # Check if it's the exact same file (hash check would be done before calling this usually,
        # but here we are resolving name collision for DIFFERENT content)
        # We assume deduplication logic handled identical files already.
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        new_filename = f"{base}_{timestamp}_{counter}{ext}"
        dest_path = os.path.join(directory, new_filename)
        counter += 1

    return dest_path

def create_dirs():
    """Creates the base directory structure."""
    print("Creating directory structure...")

    # Bots_XML and subfolders
    os.makedirs(os.path.join(ROOT_DIR, DIR_BOTS, "0-9"), exist_ok=True)
    for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        os.makedirs(os.path.join(ROOT_DIR, DIR_BOTS, char), exist_ok=True)

    # Study Materials
    os.makedirs(os.path.join(ROOT_DIR, DIR_STUDY), exist_ok=True)

    # Isolated Projects
    os.makedirs(os.path.join(ROOT_DIR, DIR_ISOLATED), exist_ok=True)

def scan_and_organize():
    """
    Main function to scan files, deduplicate, and move them.
    """
    print("Scanning files...")

    # 1. Collect all files and calculate hashes to identify duplicates
    all_files = [] # List of (path, hash)

    # We walk from ROOT_DIR
    for root, dirs, files in os.walk(ROOT_DIR):
        # Modify dirs in-place to skip ignored directories
        dirs[:] = [d for d in dirs if d not in IGNORED_NAMES and d not in IGNORED_DIRS]

        # Also skip the target directories if they already exist to avoid moving files inside them repeatedly
        # (unless we want to re-organize them? ideally yes, but flattened)
        # If we are running this script multiple times, we might want to re-scan target dirs.
        # But simpler to treat them as sources too if we want to ensure everything is in right place.
        # However, let's exclude the target roots from being *moved* if they are already correct.
        # But individual files inside might need moving if they are in wrong subfolder.
        # For safety, let's just process everything not ignored.

        for file in files:
            if file in IGNORED_NAMES:
                continue

            filepath = os.path.join(root, file)

            # Skip the script itself if it wasn't caught by IGNORED_NAMES
            if os.path.basename(filepath) == 'organize_repo.py':
                continue

            file_hash = get_file_hash(filepath)
            if file_hash:
                all_files.append({'path': filepath, 'hash': file_hash, 'filename': file})

    print(f"Found {len(all_files)} files. Analyzing duplicates...")

    # 2. Deduplicate
    unique_files = {} # hash -> path (keeps the one we want to preserve)
    duplicates = []   # List of paths to delete

    # Sort files by path length (keep shortest path usually, or maybe "deepest"?)
    # Usually keeping the one in root or closer to root is better, OR
    # if one is already in a target folder, keep that one.
    # Let's prioritize files already in target folders?
    # Or just sort by length.

    # Helper to score path priority
    def path_score(p):
        # Lower score is better (preserved)
        # Prefer paths that are NOT in the target directories yet?
        # No, prefer keeping existing organization if it matches?
        # Let's just prefer shortest path length.
        return len(p['path'])

    all_files.sort(key=path_score)

    for f in all_files:
        h = f['hash']
        if h in unique_files:
            duplicates.append(f['path'])
        else:
            unique_files[h] = f

    print(f"Identified {len(duplicates)} duplicates to remove.")

    # 3. Remove duplicates
    for dup_path in duplicates:
        try:
            os.remove(dup_path)
            print(f"Removed duplicate: {dup_path}")
        except OSError as e:
            print(f"Error removing {dup_path}: {e}")

    # 4. Move unique files
    print("Moving files to new structure...")
    moved_count = 0

    # We reiterate over the values of unique_files (which are the file dicts)
    # We verify the file still exists (it should)
    for f in unique_files.values():
        source_path = f['path']
        filename = f['filename']

        if not os.path.exists(source_path):
            continue

        category, subfolder = get_target_category(filename)

        if category:
            target_dir = os.path.join(ROOT_DIR, category)
            if subfolder:
                target_dir = os.path.join(target_dir, subfolder)

            # Create target dir if not exists (should be created by create_dirs but safe check)
            os.makedirs(target_dir, exist_ok=True)

            # Determine destination path
            # If source is already in the correct folder, skip
            # Note: os.path.samefile checks if they are the same file (inode), but here we check path string
            # to see if it's already in the right place.
            # Using os.path.abspath to compare directories
            if os.path.dirname(os.path.abspath(source_path)) == os.path.abspath(target_dir):
                continue

            dest_path = unique_path(target_dir, filename)

            try:
                shutil.move(source_path, dest_path)
                print(f"Moved: {source_path} -> {dest_path}")
                moved_count += 1
            except OSError as e:
                print(f"Error moving {source_path}: {e}")

    print(f"Moved {moved_count} files.")

def remove_empty_dirs():
    """Recursively removes empty directories."""
    print("Cleaning up empty directories...")
    # Walk bottom-up
    for root, dirs, files in os.walk(ROOT_DIR, topdown=False):
        for d in dirs:
            if d in IGNORED_NAMES or d in IGNORED_DIRS:
                continue

            dir_path = os.path.join(root, d)
            # Check if directory is strictly empty (no files, no subdirs)
            # or only contains empty subdirs which are about to be removed
            try:
                # We can just try rmdir, it fails if not empty
                os.rmdir(dir_path)
                print(f"Removed empty directory: {dir_path}")
            except OSError:
                pass # Directory not empty

def generate_index_md():
    """Generates an index.md file listing the contents."""
    print("Generating index.md...")
    index_path = os.path.join(ROOT_DIR, "index.md")

    lines = ["# Índice de Robôs e Materiais\n"]
    lines.append(f"Gerado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    # Helper to list files in a directory
    def list_dir_contents(directory, title):
        if not os.path.exists(directory):
            return

        files = sorted(os.listdir(directory))
        if not files:
            return

        lines.append(f"\n## {title}\n")

        # Check if it has subdirectories (like A-Z) or just files
        has_subdirs = any(os.path.isdir(os.path.join(directory, f)) for f in files)

        if has_subdirs:
            for item in files:
                item_path = os.path.join(directory, item)
                if os.path.isdir(item_path):
                    subfiles = sorted(os.listdir(item_path))
                    if subfiles:
                        lines.append(f"\n### {item}\n")
                        for subfile in subfiles:
                            file_path = os.path.join(directory, item, subfile)
                            rel_path = os.path.relpath(file_path, ROOT_DIR)
                            # Escape spaces for Markdown links
                            rel_path_encoded = rel_path.replace(" ", "%20")
                            lines.append(f"- [{subfile}]({rel_path_encoded})")
        else:
            for item in files:
                file_path = os.path.join(directory, item)
                if os.path.isfile(file_path):
                    rel_path = os.path.relpath(file_path, ROOT_DIR)
                    rel_path_encoded = rel_path.replace(" ", "%20")
                    lines.append(f"- [{item}]({rel_path_encoded})")

    list_dir_contents(os.path.join(ROOT_DIR, DIR_BOTS), "Robôs XML")
    list_dir_contents(os.path.join(ROOT_DIR, DIR_STUDY), "Materiais de Estudo")
    list_dir_contents(os.path.join(ROOT_DIR, DIR_ISOLATED), "Projetos Isolados")

    with open(index_path, 'w', encoding='utf-8') as f:
        f.writelines(line + '\n' for line in lines)

    print(f"Index generated at: {index_path}")

def update_readme():
    """Updates README.md with a link to the index."""
    readme_path = os.path.join(ROOT_DIR, "README.md")
    link_text = "\n\n[Ver o Índice Completo de Robôs e Materiais](index.md)"

    if os.path.exists(readme_path):
        with open(readme_path, 'r+', encoding='utf-8') as f:
            content = f.read()
            if "index.md" not in content:
                f.write(link_text)
                print("Updated README.md with index link.")
            else:
                print("README.md already contains index link.")
    else:
        # Create README if it doesn't exist? (Prompt said "Update README", presumably it exists)
        # But if not, let's create a simple one.
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write("# Repository Archive\n" + link_text)
            print("Created README.md with index link.")

def main():
    create_dirs()
    scan_and_organize()
    remove_empty_dirs()
    generate_index_md()
    update_readme()
    print("\nOrganization complete! 🚀")

if __name__ == "__main__":
    main()
