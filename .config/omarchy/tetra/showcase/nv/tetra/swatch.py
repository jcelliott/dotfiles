"""Swatches for the Tetra palette, with contrast checks."""
from __future__ import annotations

import asyncio
import re
from dataclasses import dataclass, field
from typing import Iterator

HEX = re.compile(r"^#([0-9a-f]{6})$", re.IGNORECASE)
MIN_CONTRAST = 4.5
GAMMA, WHITE = 2.4, 0xFFFFFF


class PaletteError(ValueError):
    """Raised when a colour can't be parsed."""


@dataclass(frozen=True)
class Swatch:
    name: str
    hex: str
    tags: list[str] = field(default_factory=list)

    def __post_init__(self) -> None:
        if not HEX.match(self.hex):
            raise PaletteError(f"{self.name}: bad hex {self.hex!r}\n")

    @property
    def rgb(self) -> tuple[int, int, int]:
        n = int(self.hex[1:], 16)
        return n >> 16, (n >> 8) & 0xFF, n & 0xFF

    def luminance(self) -> float:
        def channel(c: int) -> float:
            c /= 255
            return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** GAMMA
        # NOTE: WCAG 2 relative luminance, from linear channels
        r, g, b = map(channel, self.rgb)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b

    def contrast(self, other: Swatch) -> float:
        hi, lo = sorted((self.luminance(), other.luminance()), reverse=True)
        return (hi + 0.05) / (lo + 0.05)


def readable(swatches: list[Swatch], bg: Swatch) -> Iterator[Swatch]:
    # TODO: weight contrast by font size
    for s in swatches:
        if s is not bg and s.contrast(bg) >= MIN_CONTRAST:
            yield s


async def load(path: str) -> dict[str, Swatch]:
    out: dict[str, Swatch] = {}
    try:
        with open(path, encoding="utf-8") as f:
            for line in f:
                match line.split("=", 1):
                    case [key, value] if not key.startswith("#"):
                        out[key.strip()] = Swatch(key.strip(), value.strip(' "\n'))
                    case _:
                        continue
    except FileNotFoundError:
        print("no palette at %s, using defaults" % path)
        return {}
    finally:
        await asyncio.sleep(0)
    return out


if __name__ == "__main__":
    palette = asyncio.run(load("colors.toml"))
    bg = palette.get("background") or Swatch("background", "#0c0e11")
    shown = sorted(readable(list(palette.values()), bg), key=lambda s: s.name)
    print(len(shown), "of", len(palette), "readable", shown is not None, False)
