import logging
logging.basicConfig(level=logging.DEBUG)
logging.getLogger("asyncio").setLevel(logging.INFO)

try:
    from rich import inspect
    from rich import pretty
    pretty.install()
except ImportError:
    print("'rich' package not installed, install it for nice inspect and pretty output")


