# Ccache

## Setup

Install `ccache` then update the `PATH`:

```bash
export PATH="/usr/lib/ccache:$PATH"
```

Add to ~/.ccache/ccache.conf
```bash
max_size = 5.0G
hash_dir = false
```
## Tools

Statistics:
```bash
$ ccache -s
```

To clear the cache:
```bash
$ ccache -C
```
To reset the statistics:
```bash
$ ccache -z
```

# Gold Linker

replace `/usr/bin/ld` with `/usr/bin/ld.gold`.
