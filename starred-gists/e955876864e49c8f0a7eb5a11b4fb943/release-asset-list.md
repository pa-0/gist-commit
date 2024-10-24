```sh
export REPO=pact-foundation/pact-reference
gh release view --repo $REPO $tag --json assets | jq '[.[]|.[]|.name ]' |\
 jq -r 'group_by((if contains("linux") then "linux" elif contains("osx") then "osx" elif contains("windows") then "windows" else null end),
 (if contains("arm64") then "arm64" elif contains("x86_64") then "x86_64" elif contains("-x86.") then "x86" else null end)) | map({platform: .[0]|(if contains("linux") then "linux" elif contains("osx") or contains("darwin") or contains("apple") then "macos" elif contains("windows") then "windows" else null end), arch: .[0]|(if contains("arm64") then "arm64" elif contains("x86_64") then "x86_64" elif contains("-x86.") then "x86" else null end), names: map({name: .})})';
```
```json
[
  {
    "platform": null,
    "arch": null,
    "names": [
      {
        "name": "pact-cpp.h"
      },
      {
        "name": "pact.h"
      }
    ]
  },
  {
    "platform": "linux",
    "arch": null,
    "names": [
      {
        "name": "libpact_ffi-linux-aarch64.a.gz"
      },
      {
        "name": "libpact_ffi-linux-aarch64.a.gz.sha256"
      },
      {
        "name": "libpact_ffi-linux-aarch64.so.gz"
      },
      {
        "name": "libpact_ffi-linux-aarch64.so.gz.sha256"
      }
    ]
  },
  {
    "platform": "linux",
    "arch": "x86_64",
    "names": [
      {
        "name": "libpact_ffi-linux-x86_64-musl.a.gz"
      },
      {
        "name": "libpact_ffi-linux-x86_64-musl.a.gz.sha256"
      },
      {
        "name": "libpact_ffi-linux-x86_64.a.gz"
      },
      {
        "name": "libpact_ffi-linux-x86_64.a.gz.sha256"
      },
      {
        "name": "libpact_ffi-linux-x86_64.so.gz"
      },
      {
        "name": "libpact_ffi-linux-x86_64.so.gz.sha256"
      }
    ]
  },
  {
    "platform": "macos",
    "arch": null,
    "names": [
      {
        "name": "libpact_ffi-osx-aarch64-apple-darwin.a.gz"
      },
      {
        "name": "libpact_ffi-osx-aarch64-apple-darwin.a.gz.sha256"
      },
      {
        "name": "libpact_ffi-osx-aarch64-apple-darwin.dylib.gz"
      },
      {
        "name": "libpact_ffi-osx-aarch64-apple-darwin.dylib.gz.sha256"
      }
    ]
  },
  {
    "platform": "macos",
    "arch": "x86_64",
    "names": [
      {
        "name": "libpact_ffi-osx-x86_64.a.gz"
      },
      {
        "name": "libpact_ffi-osx-x86_64.a.gz.sha256"
      },
      {
        "name": "libpact_ffi-osx-x86_64.dylib.gz"
      },
      {
        "name": "libpact_ffi-osx-x86_64.dylib.gz.sha256"
      }
    ]
  },
  {
    "platform": "windows",
    "arch": "x86_64",
    "names": [
      {
        "name": "pact_ffi-windows-x86_64.dll.gz"
      },
      {
        "name": "pact_ffi-windows-x86_64.dll.gz.sha256"
      },
      {
        "name": "pact_ffi-windows-x86_64.dll.lib.gz"
      },
      {
        "name": "pact_ffi-windows-x86_64.dll.lib.gz.sha256"
      },
      {
        "name": "pact_ffi-windows-x86_64.lib.gz"
      },
      {
        "name": "pact_ffi-windows-x86_64.lib.gz.sha256"
      }
    ]
  }
  ```