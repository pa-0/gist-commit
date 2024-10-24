Last week a post regarding hashing[^1] from u/S34nfa gave me the last push I needed to stop procrastinating on this.

Currently my son is pretty invested in learning AHK to "_help a friend_" (I'm guessing it has nothing to do the fact the friend is the girl he's obviously into). Yesterday's lesson was dynamic elements and how to work with a flexible dataset. We did this script[^2], hope you find it useful or at very least serves you to see the concepts applied.

- It has a "wide" mode: full contents of the hashes are shown (weird looking when displaying sha512).
- "Non-wide" mode: shows the first and last 8 characters of the hash with an ellipsis in the middle (full hash on mouse over).
- Upon start, Clipboard is scanned for text in the form of a hash; if found, it'll automatically start the hashing with the proper algorithm (32 hex chars: MD5, 40: SHA1, 64: SHA256...).
- It can display any combination between the usual suspects from CryptCreateHash[^3]
- Gui elements are created/positioned dynamically and don't have fixed sizing (the size is based on content).
- It has no buttons, keyboard arrows provide navigation between algorithms (all within a radio group).
- The hash verification field changes color (green/red) for the comparison (making irrelevant not seeing the whole hash).

## Screens

- Wide mode, all algorithms, error image[^4].
- Regular mode, all algorithms, match, Tooltip image[^5].
- Wide mode, useful algorithms, error image[^6].
- Regular mode, useful algorithms, match, Tooltip image[^7].

## Usage

- Open the "Send To" folder
  - Click **Start**, select **Run**, type `shell:SendTo`
- Place a shortcut to the script in there
- In any Explorer use the "Send To" menu with any file.
  - If a hash is already in the clipboard the process is automatic.

## Example

Any file will do, AutoHotkey version check helper[^8] is commonly (ab)used as example. Right click, save as... The hashes below correspond to the version `1.1.33.10`.

| Algorithm | Hash
|        -: | :-
| md2       | f7cb776fbad83e5886925aa6ec11d447
| md4       | 7c2784a93fdec04f15cd8c75f47c1f4f
| md5       | 35d44339f9e887425e084c370e1bd957
| sha1      | e17f981ba7a00534b7fc8d7d10627597f34dbe65
| sha256    | 6a628ad6385ad0db86b52bc29b081683b2b2cb57f97aaab663808641bdf1de2d
| sha384    | dee3eb24ce137c4468b62e6a47f5da7d932b05f4a99dff38c3c8c69ebd5e591c03630f8e83afae8b20fea1be5c9a4651
| sha512    | ac4caebe660dd99562b5f23a5b22fb5c819a90b6145e8eb6946ed56ce3c947a9b18a36718ea3a5bcaeb865b7b528906ba359e7b5cb569c9d1460e04bc0e32740

<sup>1: The hashing function can be swapped for libcrypt.ahk[^9]'s `LC_CalcFileHash()` if you already have it in your _function library_.</sup>

**EDIT**: As pointed out by /u/PotatoInBrackets[^10] the code had no comments and could be confusing, the gist is updated but I totally suck at comments.

---


[^1]: https://redd.it/lxlj1a
[^2]: https://git.io/JXhbO
[^3]: https://docs.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-cryptcreatehash
[^4]: https://i.imgur.com/4wbCCYM.png
[^5]: https://i.imgur.com/euyHj3M.png
[^6]: https://i.imgur.com/UyNFKwB.png
[^7]: https://i.imgur.com/WnFwDzn.png
[^8]: https://autohotkey.com/download/1.1/version.txt
[^9]: https://github.com/ahkscript/libcrypt.ahk#libcryptahk
[^10]: https://www.reddit.com/u/PotatoInBrackets