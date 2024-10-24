# `Import Keybase PGP 2 GPG`

Import [Keybase](https://keybase.io/) PGP -> [Gnu](https://gnupg.org/) GPG keyring.

## 1. Import public PGP

```sh
keybase pgp export|gpg --import -
```

## 2. Migrate private PGP

```sh
keybase pgp export -s|gpg --allow-secret-key-import --import -
```

## 3. Update trust level

```sh
gpg --edit-key you@keybase.io
```

Select:

- trust
- 5
- y
- save

Done 😎