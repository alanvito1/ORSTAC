#!/usr/bin/env python3
"""
The Asset Curator - Repository Organizer Script

This script organizes a chaotic repository of trading bots and learning materials
into a clean structure:
1. /Bots_XML/ -> Subfolders A-Z and 0-9 for XML bots.
2. /Materiais_de_Estudo/ -> PDFs, videos, and other study materials.
3. /Projetos_Isolados/ -> Everything else (MetaTrader files, zips, code, etc.).
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
    for part in parts:
        if part in IGNORED_NAMES or part in IGNORED_DIRS:
            return True
    return False

def get_target_category(filename):
    """Determines the target category and subfolder for a file."""
    name, ext = os.path.splitext(filename)
    ext = ext.lower()

    if ext in EXT_XML:
        first_char = ''
        for char in name:
            if char.isalnum():
                first_char = char
                break
        
        if not first_char:
            return DIR_ISOLATED, None
            
        if first_char.isdigit():
            return DIR_BOTS, "0-9"
        else:
            return DIR_BOTS, first_char.upper()

    if ext in EXT_STUDY:
        return DIR_STUDY, None

    return DIR_ISOLATED, None

def unique_path(directory, filename):
    """Generates a unique path for a file in the destination directory."""
    base, ext = os.path.splitext(filename)
    counter = 1
    new_filename = filename
    dest_path = os.path.join(directory, new_filename)
    
    while os.path.exists(dest_path):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        new_filename = f"{base}_{timestamp}_{counter}{ext}"
        dest_path = os.path.join(directory, new_filename)
        counter += 1
        
    return dest_path

def create_dirs():
    """Creates the base directory structure."""
    print("Creating directory structure...")
    os.makedirs(os.path.join(ROOT_DIR, DIR_BOTS, "0-9"), exist_ok=True)
    for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        os.makedirs(os.path.join(ROOT_DIR, DIR_BOTS, char), exist_ok=True)
        
    os.makedirs(os.path.join(ROOT_DIR, DIR_STUDY), exist_ok=True)
    os.makedirs(os.path.join(ROOT_DIR, DIR_ISOLATED), exist_ok=True)

def scan_and_organize():
    """Main function to scan files, deduplicate, and move them."""
    print("Scanning files...")
    all_files = [] 
    
    for root, dirs, files in os.walk(ROOT_DIR):
        dirs[:] = [d for d in dirs if d not in IGNORED_NAMES and d not in IGNORED_DIRS]
        
        for file in files:
            if file in IGNORED_NAMES:
                continue
                
            filepath = os.path.join(root, file)
            
            if os.path.basename(filepath) == 'organize_repo.py':
                continue

            file_hash = get_file_hash(filepath)
            if file_hash:
                all_files.append({'path': filepath, 'hash': file_hash, 'filename': file})

    print(f"Found {len(all_files)} files. Analyzing duplicates...")

    unique_files = {} 
    duplicates = []   

    def path_score(p):
        return len(p['path'])

    all_files.sort(key=path_score)

    for f in all_files:
        h = f['hash']
        if h in unique_files:
            duplicates.append(f['path'])
        else:
            unique_files[h] = f

    print(f"Identified {len(duplicates)} duplicates to remove.")

    for dup_path in duplicates:
        try:
            os.remove(dup_path)
            print(f"Removed duplicate: {dup_path}")
        except OSError as e:
            print(f"Error removing {dup_path}: {e}")

    print("Moving files to new structure...")
    moved_count = 0
    
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
            
            os.makedirs(target_dir, exist_ok=True)
            
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
    for root, dirs, files in os.walk(ROOT_DIR, topdown=False):
        for d in dirs:
            if d in IGNORED_NAMES or d in IGNORED_DIRS:
                continue
            
            dir_path = os.path.join(root, d)
            try:
                os.rmdir(dir_path)
                print(f"Removed empty directory: {dir_path}")
            except OSError:
                pass 

def generate_index_md():
    """Generates an index.md file listing the contents."""
    print("Generating index.md...")
    index_path = os.path.join(ROOT_DIR, "index.md")
    
    lines = ["# Índice de Robôs e Materiais\n"]
    lines.append(f"Gerado em: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    def list_dir_contents(directory, title):
        if not os.path.exists(directory):
            return
        
        files = sorted(os.listdir(directory))
        if not files:
            return

        lines.append(f"\n## {title}\n")
        
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