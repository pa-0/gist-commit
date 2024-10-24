#!/usr/bin/env python3.9

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

import os
import time
import xxhash
from collections import namedtuple
from pathlib import Path
from typing import Dict, List, Optional


TARGET_DIRS = [
    r"C:\Insert\Your\Dir\Here",
    r"D:\And\Here\If\More\Than\One",
    r"E:\Add\Items\As\Necessary",
]
BLOCK_SIZE = 4096
FILE_READ_CHUNKSIZE = BLOCK_SIZE << 5  # lshift 5 empirically determined to give best perf

Problematic = namedtuple("Problematic", ["path", "problem"])


class FileDat:
    # XXH3 might be faster, but we want as collision-free as possible
    # Because there's a danger of irrecoverable data loss if algo chosen exhibits too many collisions
    # (Data loss due to you deleting an "alleged dupe" while it's in fact not)
    # Maybe the probability of that happening is statistically very small, but let's be safe than sorry
    HASH_METHOD = xxhash.xxh128
    THREE_BLOCKS = 3 * BLOCK_SIZE

    def __init__(self, filepath: Path):
        assert isinstance(filepath, Path)
        self.filepath: Path = filepath
        self._stat: Optional[os.stat_result] = None
        self._endshash: Optional[bytes] = None
        self._wholehash: Optional[bytes] = None
        self._hasher = FileDat.HASH_METHOD()

    @property
    def stat(self):
        if self._stat is None:
            self._stat = self.filepath.stat()
        return self._stat

    @property
    def ends_hash(self):
        if self._endshash is None:
            with open(self.filepath, "rb") as fin:
                hasher = self._hasher
                # Files 3 blocksize or larger will have only 1st block and last 1 (or 1 + a partial) block read
                if self.stat.st_size >= FileDat.THREE_BLOCKS:
                    hasher.update(fin.read(BLOCK_SIZE))
                    end_block = (self.stat.st_size // BLOCK_SIZE) - 1
                    end_seek = end_block * BLOCK_SIZE
                    fin.seek(end_seek)
                # Files smaller than 3 blocksize skips the seek above, so they will be hashed in whole
                # Now let's do some memory-limited reads:
                while chunk := fin.read(FILE_READ_CHUNKSIZE):
                    hasher.update(chunk)
            self._endshash = hasher.digest()
        return self._endshash

    @property
    def whole_hash(self):
        if self._wholehash is None:
            # See note in FileDat.ends_hash
            if self.stat.st_size < FileDat.THREE_BLOCKS:
                self._wholehash = self._endshash
            else:
                hasher = self._hasher
                with open(self.filepath, "rb") as fin:
                    while chunk := fin.read(FILE_READ_CHUNKSIZE):
                        hasher.update(chunk)
                self._wholehash = self._hasher.digest()
        return self._wholehash


def gather_filedats(
    targroot: Path,
    filedats_coll: Dict[int, List[FileDat]],
    problematics: List[Problematic],
) -> int:
    files_count = 0
    print(f"Scanning {targroot} ...")
    targfiledats_g = (FileDat(tp) for tp in targroot.rglob("*") if tp.is_file())
    for tfd in targfiledats_g:
        try:
            filedats_coll.setdefault(tfd.stat.st_size, []).append(tfd)
            files_count += 1
        except Exception as e:
            problematics.append(Problematic(path=tfd.filepath, problem=e))
    return files_count


def identify_dupes(filedats: List[FileDat], problematics: List[Problematic]) -> int:
    fff = None  # Suppress "might be referenced before assignment" warning on line 126
    can_save = 0

    # First we check the hash of the 'ends' (head & tail) of the file
    # Saves time when different files are very large
    # Example cases: 2 files of exact same lengths but differing in their headers/tails,
    # such as differently-tagged -- but identical sized -- audio files.
    by_ends: Dict[bytes, List[FileDat]] = {}
    for fd in filedats:
        try:
            by_ends.setdefault(fd.ends_hash, []).append(fd)
        except Exception as e:
            problematics.append(Problematic(path=fd.filepath, problem=e))
    for fdlist in by_ends.values():
        if len(fdlist) < 2:
            continue
        # Next we grab files with same ends_hash and check hash of whole file
        by_whole: Dict[bytes, List[FileDat]] = {}
        for fd2 in fdlist:
            by_whole.setdefault(fd2.whole_hash, []).append(fd2)
        for fdlist2 in by_whole.values():
            if len(fdlist2) < 2:
                continue
            print("  These files are identical:")
            for fff in fdlist2:
                print(f"    {fff.filepath}")
            can_save += (len(fdlist2) - 1) * fff.stat.st_size
    return can_save


def main():
    problematics: List[Problematic] = []

    filedats_bysize: Dict[int, List[FileDat]] = {}
    all_count = 0
    for targpath in TARGET_DIRS:
        targroot = Path(targpath)
        if not targroot.exists():
            continue
        all_count += gather_filedats(targroot, filedats_bysize, problematics)
    print(f"\nTotal of {all_count} files from {len(TARGET_DIRS)} dirs")
    print(f"  ... {len(filedats_bysize)} file size bins")

    # Remove size bins with just 1 member
    filedats_bysize = {
        sz: flist for sz, flist in filedats_bysize.items() if len(flist) > 1
    }
    print(f"  ... {len(filedats_bysize)} size bins with more than one file each")

    # Zero-sized files are _always_ identical, let's just print them out :-)
    if 0 in filedats_bysize:
        print("Zero-sized files:")
        for fd in filedats_bysize[0]:
            print(" ", str(fd.filepath))
        del filedats_bysize[0]

    total_savings = 0

    # Sort .keys() then grab the value is much faster than sort .items()
    # (Yes, tested using timeit.repeat(). Reliably 20%-30% faster!)
    for sz in sorted(filedats_bysize.keys()):
        flist = filedats_bysize[sz]
        print(f"Checking {len(flist)} files of size {sz:,} ...")
        dupe_size = identify_dupes(flist, problematics)
        if not dupe_size:
            print("  No dupes")
        else:
            total_savings += dupe_size

    print(
        f"\nYou potentially can save {total_savings:,} bytes if you delete the dupes..."
    )

    if problematics:
        print("\nThese files are problematic")
        for pf in problematics:
            print(f"  {pf.path}: {repr(pf.problem)}")


if __name__ == "__main__":
    started = time.monotonic()
    main()
    elapsed = time.monotonic() - started
    print(f"\nDupeFinder completed in {elapsed:.2f} seconds")
