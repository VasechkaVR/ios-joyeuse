#!/usr/bin/env python3
"""Validate joyeuse Adreno firmware inputs and report SHA-256 digests."""
import hashlib
import struct
import sys
import zlib
from pathlib import Path

EXPECTED = {
    "a618_gmu.bin": None,
    "a630_sqe.fw": None,
    "a615_zap.mdt": 0x1ACC,
    "a615_zap.b02": 0x7C0,
}

def firmware_properties(directory="fw"):
    root = Path(directory)
    props = []
    names = {
        "a618_gmu.bin": ("gmu-firmware", "gmu-crc32"),
        "a630_sqe.fw": ("sqe-firmware", "sqe-firmware-crc32"),
        "a615_zap.mdt": ("zap-metadata", "zap-metadata-crc32"),
        "a615_zap.b02": ("zap-code", "zap-code-crc32"),
    }
    for filename, (data_prop, crc_prop) in names.items():
        path = root / filename
        if not path.is_file():
            raise FileNotFoundError(f"missing Adreno firmware: {path}")
        data = path.read_bytes()
        expected = EXPECTED[filename]
        if expected is not None and len(data) != expected:
            raise ValueError(f"{path}: {len(data):#x} bytes, expected {expected:#x}")
        digest = hashlib.sha256(data).hexdigest().encode("ascii") + b"\\0"
        props.append((data_prop, 0, data))
        props.append((data_prop + "-sha256", 0, digest))
        props.append((crc_prop, 0, struct.pack("<I", zlib.crc32(data))))
    return props

def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "fw")
    missing = []
    for name, size in EXPECTED.items():
        path = root / name
        if not path.is_file():
            print(f"MISSING {path}")
            missing.append(name)
            continue
        data = path.read_bytes()
        if size is not None and len(data) != size:
            print(f"ERROR {path}: {len(data):#x} bytes, expected {size:#x}")
            return 1
        print(f"{name} sha256={hashlib.sha256(data).hexdigest()} size={len(data):#x}")
    return 1 if missing else 0

if __name__ == "__main__":
    raise SystemExit(main())
