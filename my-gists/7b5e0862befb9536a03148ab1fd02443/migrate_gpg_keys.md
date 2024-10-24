# ` Migrate GPG Keys`

## 1. Export keys

Obtain your ID:

```bash
gpg --list-secret-keys --keyid-format LONG
```

This snippet is from output: `rsa4096/C228AC4C92BD20D3`

After the key size `rsa4096/` is a number which is your ID, write public key to file:

```bash
gpg --export -a [ ID ] > gpg-pub.asc
```

Reapeat same with private key, it might be password protected, you'll be prompted to enter it:

```bash
gpg --export-secret-keys -a [ ID ] > gpg-sc.asc
```

## 2. Import keys

Public:

```bash
gpg --import gpg-pub.asc
```

Private:

```bash
gpg --import gpg-sc.asc
```

Adjust the trust level:

```bash
gpg --edit-key [ ID ]
```
