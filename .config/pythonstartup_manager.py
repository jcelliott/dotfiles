# Python startup script manager
#
# Loads a global pythonstartup.py next to this script and then loads a
# project-specific .pythonstartup.py from the current directory

import hashlib
import json
from pathlib import Path


def find_project_startup():
    current_dir = Path.cwd()
    home_dir = Path.home()
    
    for parent in [current_dir] + list(current_dir.parents):
        if parent == home_dir:
            break
        startup_file = parent / '.pythonstartup.py'
        if startup_file.exists():
            return startup_file
    
    return None

def get_trusted_hashes_file():
    return Path(__file__).parent / '.pythonstartup_trusted_hashes.json'

def load_trusted_hashes():
    hashes_file = get_trusted_hashes_file()
    if hashes_file.exists():
        try:
            return json.loads(hashes_file.read_text())
        except (json.JSONDecodeError, OSError):
            return {}
    return {}

def save_trusted_hash(file_path, file_hash):
    hashes_file = get_trusted_hashes_file()
    trusted_hashes = load_trusted_hashes()
    trusted_hashes[str(file_path)] = file_hash
    hashes_file.write_text(json.dumps(trusted_hashes, indent=2, sort_keys=True))

def get_file_hash(file_path):
    return hashlib.sha256(file_path.read_bytes()).hexdigest()

def prompt_user_to_trust(file_path, content):
    print(f"\nFound project startup file: {file_path}\n")
    print("-" * 80)
    print(content)
    print("-" * 80)
    
    while True:
        response = input("Do you want to load this file? (y/n): ").lower().strip()
        if response in ['y', 'yes']:
            return True
        elif response in ['n', 'no']:
            return False
        print("Please answer 'y' or 'n'")

def load_project_startup():
    project_startup = find_project_startup()
    if not project_startup:
        return
    
    try:
        content = project_startup.read_text()
        file_hash = get_file_hash(project_startup)
        trusted_hashes = load_trusted_hashes()
        
        if trusted_hashes.get(str(project_startup)) == file_hash:
            exec(content)
            print(f"Loaded trusted project startup: {project_startup}")
        else:
            if prompt_user_to_trust(project_startup, content):
                save_trusted_hash(project_startup, file_hash)
                exec(content)
                print(f"Loaded and trusted project startup: {project_startup}")
            else:
                print(f"Skipped loading project startup: {project_startup}")
    except Exception as e:
        print(f"Error loading project startup {project_startup}: {e}")

def load_global_startup():
    global_startup_file = Path(__file__).parent / 'pythonstartup.py'
    if global_startup_file.exists():
        global_startup_content = global_startup_file.read_text()
        exec(global_startup_content)


load_global_startup()
load_project_startup()

