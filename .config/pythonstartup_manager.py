# Python startup script manager
#
# Loads a global pythonstartup.py next to this script and then loads a
# project-specific .pythonstartup.py from the current directory
import hashlib
import json
import os
import sys
from pathlib import Path

def get_script_path():
    """Get the path of this startup script, handling both regular Python and IPython."""
    try:
        # Try to use __file__ (works in regular Python)
        return Path(__file__)
    except NameError:
        # __file__ is not defined in IPython interactive shell
        # Use alternative methods to find the script location
        
        # Method 1: Check PYTHONSTARTUP environment variable
        startup_env = os.environ.get('PYTHONSTARTUP')
        if startup_env and os.path.exists(startup_env):
            return Path(startup_env)
        
        # Method 2: Use sys.argv[0] if available
        if sys.argv and sys.argv[0]:
            script_path = Path(sys.argv[0])
            if script_path.exists():
                return script_path
        
        # Method 3: Default to home directory .pythonstartup location
        default_path = Path.home() / '.pythonstartup.py'
        if default_path.exists():
            return default_path
        
        # If all else fails, use current directory
        return Path.cwd() / 'pythonstartup.py'

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
    script_path = get_script_path()
    return script_path.parent / '.pythonstartup_trusted_hashes.json'

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
            exec(content, globals())
            print(f"Loaded trusted project startup: {project_startup}")
        else:
            if prompt_user_to_trust(project_startup, content):
                save_trusted_hash(project_startup, file_hash)
                exec(content, globals())
                print(f"Loaded and trusted project startup: {project_startup}")
            else:
                print(f"Skipped loading project startup: {project_startup}")
    except Exception as e:
        print(f"Error loading project startup {project_startup}: {e}")

def load_global_startup():
    script_path = get_script_path()
    global_startup_file = script_path.parent / 'pythonstartup.py'
    if global_startup_file.exists():
        try:
            global_startup_content = global_startup_file.read_text()
            exec(global_startup_content, globals())
            print(f"Loaded global startup: {global_startup_file}")
        except Exception as e:
            print(f"Error loading global startup {global_startup_file}: {e}")


load_global_startup()
load_project_startup()
