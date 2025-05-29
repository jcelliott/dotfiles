# Global python startup script
# Anything that should be available in every interactive python session should
# go here
# Project-specific configuration can go in a .pythonstartup.py file in any
# directory and will be loaded by the manager.

import time
from contextlib import contextmanager

import logging
logging.basicConfig(level=logging.DEBUG)
logging.getLogger("asyncio").setLevel(logging.INFO)

### Common helper libraries to load ###

try:
    from rich import inspect
    from rich import pretty
    pretty.install()
except ImportError:
    print("'rich' package not installed, install it for nice inspect and pretty output")

### Helper functions ###

# Use IPython "%time" magic command:
# %time result = some_function(arg1, arg2)

# Usage: wrap existing call
# with timer():
#     result = some_function(arg1, arg2)
@contextmanager
def timer():
    start = time.perf_counter()
    yield
    end = time.perf_counter()
    print(f"Execution time: {end - start:.4f} seconds")

print("Loaded global python startup")
