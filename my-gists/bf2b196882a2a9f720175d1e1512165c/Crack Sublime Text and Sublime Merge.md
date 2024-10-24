### Note

1. If you can, please purchase the genuine license through [the official channel](https://www.sublimehq.com/store/) and support the software developer.
1. All crack methods here are implemented by [**@leogx9r**](https://gist.github.com/leogx9r).
1. **All data is not guaranteed to be authoritative or correct, nor has it been tested across the platform, nor is it responsible for any errors, lost data, etc. in practice! Please assess yourself!!!**
1. I am only within the ability to update the information based on the existing crack methods until the existing rules fail.

---

#### Sublime Patcher Script for personal use
> The code implementation is very poor.<br>
  https://gist.github.com/maboloshi/5baecbddacf43855f13240b63be5673d

### ToC

|                | Sublime Text                                                                                                                                       | Sublime Merge   |
| -------------- | :----------: | :-------------: |
| Stable channel | <a href="#user-content-ST_SC_Win64">win</a> / <a href="#user-content-ST_SC_Linux">linux</a> / <a href="#user-content-ST_SC_macOS">mac</a> / <a href="#user-content-ST_SC_macOS_ARM64">mac-arm64</a> | <a href="#user-content-SM_SC_Win64">win</a> / <a href="#user-content-SM_SC_Linux">linux</a> / <a href="#user-content-SM_SC_macOS">mac</a> / <a href="#user-content-SM_SC_macOS_ARM64">mac-arm64</a>
| Dev channel    | <a href="#user-content-ST_DC_Win64">win</a> / <a href="#user-content-ST_DC_Linux">linux</a> / <a href="#user-content-ST_DC_macOS">mac</a> / <a href="#user-content-ST_DC_macOS_ARM64">mac-arm64</a> | <a href="#user-content-SM_DC_Win64">win</a> / <a href="#user-content-SM_DC_Linux">linux</a> / <a href="#user-content-SM_DC_macOS">mac</a> / <a href="#user-content-SM_DC_macOS_ARM64">mac-arm64</a>

---

### How to Crack Sublime Text, Stable Channel, Build 4152

Thanks to [**@leogx9r**](https://gist.github.com/leogx9r) for providing cracking methods.
> https://gist.github.com/JerryLokjianming/71dac05f27f8c96ad1c8941b88030451?permalink_comment_id=3762200#gistcomment-3762200
> https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3802197#gistcomment-3802197
> https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3803204#gistcomment-3803204

#### <div id="ST_SC_Win64">Win64</div>

Desciption                       | Offset     | Original             | Patched
-------------------------------- | :--------: | -------------------- | --
Initial License Check            | 0x000A8D78 | 55 41 57 41          | 48 31 C0 C3
Persistent License Check 1       | 0x000071D0 | E8 17 FE 20 00       | 90 90 90 90 90
Persistent License Check 2       | 0x000071E9 | E8 FE FD 20 00       | 90 90 90 90 90
Disable Server Validation Thread | 0x000AAB3E | 55 56 57 48 83 EC 30 | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x000A8945 | 55                   | C3
Disable Crash Reporter           | 0x00000400 | 41                   | C3

> for 4117, 4118: https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3927712#gistcomment-3927712

##### Bat Script

```bat
:: for Win64
cd /d "C:\Program Files\Sublime Text" || exit
certutil -hashfile sublime_text.exe md5 | find /i "15BB398D5663B89A44372EF15F70A46F" || exit
echo 000A8D78: 48 31 C0 C3          | xxd -r - sublime_text.exe
echo 000071D0: 90 90 90 90 90       | xxd -r - sublime_text.exe
echo 000071E9: 90 90 90 90 90       | xxd -r - sublime_text.exe
echo 000AAB3E: 48 31 C0 48 FF C0 C3 | xxd -r - sublime_text.exe
echo 000A8945: C3                   | xxd -r - sublime_text.exe
echo 00000400: C3                   | xxd -r - sublime_text.exe
```

PS：[**xxd.exe**](https://github.com/git-for-windows/git-sdk-64/raw/main/usr/bin/xxd.exe) extracted from [git for windows](https://github.com/git-for-windows/git-sdk-64)

**The license can be any string.**

Blocked by **Microsoft Defender SmartScreen** -> **More Info** -> **Run Anyway**

  <details>
    <summary>Screenshot</summary>

    ![Screenshot](https://i.imgur.com/t4QlRZ6.png)

    ![Screenshot](https://i.imgur.com/18372Rh.png)
  </details>

#### <div id="ST_SC_Linux">Linux</div>

Desciption                       | Offset     | Original             | Patched
-------------------------------- | :--------: | -------------------- | --
Initial License Check            | 0x00415013 | 55 41 57 41          | 48 31 C0 C3
Persistent License Check 1       | 0x00409037 | E8 C0 CC 12 00       | 90 90 90 90 90
Persistent License Check 2       | 0x0040904F | E8 A8 CC 12 00       | 90 90 90 90 90
Disable Server Validation Thread | 0x00416CA4 | 55 41 56 53 41 89 F6 | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x00414C82 | 41                   | C3
Disable Crash Reporter           | 0x003FA310 | 55                   | C3

##### Bash Script

```bash
# for Linux
cd /opt/sublime_text || exit
md5sum -c <<<"7038C3B1CC79504602DA70599D4CCCE9  sublime_text" || exit
echo 00415013: 48 31 C0 C3          | xxd -r - sublime_text
echo 00409037: 90 90 90 90 90       | xxd -r - sublime_text
echo 0040904F: 90 90 90 90 90       | xxd -r - sublime_text
echo 00416CA4: 48 31 C0 48 FF C0 C3 | xxd -r - sublime_text
echo 00414C82: C3                   | xxd -r - sublime_text
echo 003FA310: C3                   | xxd -r - sublime_text
```

#### <div id="ST_SC_macOS">macOS</div>

Desciption                       | Offset     | Original             | Patched
-------------------------------- | :--------: | -------------------- | --
Initial License Check            | 0x0009F313 | 55 48 89 E5          | 48 31 C0 C3
Persistent License Check 1       | 0x00009CEF | E8 3C 2D 13 00       | 90 90 90 90 90
Persistent License Check 2       | 0x00009D07 | E8 24 2D 13 00       | 90 90 90 90 90
Disable Server Validation Thread | 0x000A085D | 55 48 89 E5 41 57 41 | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x0009EF0E | 55                   | C3
Disable Crash Reporter           | 0x00002A87 | 55                   | C3

##### Bash Script

```bash
# for MacOS
cd "/Applications/Sublime Text.app/Contents/MacOS/" || exit
md5 -q sublime_text | grep -i "B07FDB3A228A46DF1CC178FE60B64D3B" || exit
echo 0009F313: 48 31 C0 C3          | xxd -r - sublime_text
echo 00009CEF: 90 90 90 90 90       | xxd -r - sublime_text
echo 00009D07: 90 90 90 90 90       | xxd -r - sublime_text
echo 000A085D: 48 31 C0 48 FF C0 C3 | xxd -r - sublime_text
echo 0009EF0E: C3                   | xxd -r - sublime_text
echo 00002A87: C3                   | xxd -r - sublime_text
```

##### Re-Sign App

```bash
codesign --force --deep --sign - "/Applications/Sublime Text.app"
```

> Requires `Apple Command Line Tools` to be installed

#### <div id="ST_SC_macOS_ARM64">macOS (ARM64)</div>

> Based on: https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3929427#gistcomment-3929427

Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ------------------------| --
Initial License Check            | 0x01060C90 | FC 6F BA A9 E6 03 1E AA | E0 03 1F AA C0 03 5F D6
Persistent License Check 1       | 0x00FEAD18 | 40 BB 03 94             | 1F 20 03 D5
Persistent License Check 2       | 0x00FEAD2C | 3B BB 03 94             | 1F 20 03 D5
Disable Server Validation Thread | 0x01061F28 | F6 57 BD A9             | C0 03 5F D6
Disable License Notify Thread    | 0x01060908 | FC 6F BD A9             | C0 03 5F D6
Disable Crash Reporter           | 0x00FE5780 | FC 6F BC A9             | C0 03 5F D6

##### Bash Script

```bash
# for macOS (ARM64)
cd "/Applications/Sublime Text.app/Contents/MacOS/" || exit
md5 -q sublime_text | grep -i "B07FDB3A228A46DF1CC178FE60B64D3B" || exit
echo 01060C90: E0 03 1F AA C0 03 5F D6 | xxd -r - sublime_text
echo 00FEAD18: 1F 20 03 D5             | xxd -r - sublime_text
echo 00FEAD2C: 1F 20 03 D5             | xxd -r - sublime_text
echo 01061F28: C0 03 5F D6             | xxd -r - sublime_text
echo 01060908: C0 03 5F D6             | xxd -r - sublime_text
echo 00FE5780: C0 03 5F D6             | xxd -r - sublime_text
```

##### Re-Sign App

```bash
codesign --force --deep --sign - "/Applications/Sublime Text.app"
```

> Requires `Apple Command Line Tools` to be installed

---

### How to Crack Sublime Text, Dev Channel, Build 4154

Thanks to [**@leogx9r**](https://gist.github.com/leogx9r) for providing cracking methods.
> https://gist.github.com/JerryLokjianming/71dac05f27f8c96ad1c8941b88030451?permalink_comment_id=3762200#gistcomment-3762200
> https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3802197#gistcomment-3802197
> https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3803204#gistcomment-3803204

#### <div id="ST_DC_Win64">Win64</div>

Desciption                       | Offset     | Original             | Patched
-------------------------------- | :--------: | -------------------- | --
Initial License Check            | 0x0009E47C | 55 41 57 41          | 48 31 C0 C3
Persistent License Check 1       | 0x0000647C | E8 23 7C 20 00       | 90 90 90 90 90
Persistent License Check 2       | 0x00006495 | E8 0A 7C 20 00       | 90 90 90 90 90
Disable Server Validation Thread | 0x000A0222 | 55 56 57 48 83 EC 30 | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x0009E043 | 55                   | C3
<!--  Disable Crash Reporter           | 0x00000400 | 41                   | C3-->

> for 4117, 4118: https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3927712#gistcomment-3927712

##### Bat Script

```bat
:: for Win64
cd /d "C:\Program Files\Sublime Text" || exit
certutil -hashfile sublime_text.exe md5 | find /i "ADF277D39672D83637AB708FC45413C8" || exit
echo 0009E47C: 48 31 C0 C3          | xxd -r - sublime_text.exe
echo 0000647C: 90 90 90 90 90       | xxd -r - sublime_text.exe
echo 00006495: 90 90 90 90 90       | xxd -r - sublime_text.exe
echo 000A0222: 48 31 C0 48 FF C0 C3 | xxd -r - sublime_text.exe
echo 0009E043: C3                   | xxd -r - sublime_text.exe
```

PS：[**xxd.exe**](https://github.com/git-for-windows/git-sdk-64/raw/main/usr/bin/xxd.exe) extracted from [git for windows](https://github.com/git-for-windows/git-sdk-64)

**The license can be any string.**

Blocked by **Microsoft Defender SmartScreen** -> **More Info** -> **Run Anyway**

  <details>
    <summary>Screenshot</summary>

    ![Screenshot](https://i.imgur.com/t4QlRZ6.png)

    ![Screenshot](https://i.imgur.com/18372Rh.png)
  </details>

#### <div id="ST_DC_Linux">Linux</div>

Desciption                       | Offset     | Original             | Patched
-------------------------------- | :--------: | -------------------- | --
Initial License Check            | 0x00443F94 | 55 41 57 41          | 48 31 C0 C3
Persistent License Check 1       | 0x0042B210 | E8 37 44 14 00       | 90 90 90 90 90
Persistent License Check 2       | 0x0042B228 | E8 1F 44 14 00       | 90 90 90 90 90
Disable Server Validation Thread | 0x00445EB6 | 55 41 56 53 41 89 F6 | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x00443BF8 | 41                   | C3
<!--  Disable Crash Reporter           | 0x003F9280 | 55                   | C3-->

##### Bash Script

```bash
# for Linux
cd /opt/sublime_text || exit
md5sum -c <<<"8836FE092DBB7BC8D3D2375D34510CA9  sublime_text" || exit
echo 00443F94: 48 31 C0 C3          | xxd -r - sublime_text
echo 0042B210: 90 90 90 90 90       | xxd -r - sublime_text
echo 0042B228: 90 90 90 90 90       | xxd -r - sublime_text
echo 00445EB6: 48 31 C0 48 FF C0 C3 | xxd -r - sublime_text
echo 00443BF8: C3                   | xxd -r - sublime_text
```

#### <div id="ST_DC_macOS">macOS</div>

Desciption                       | Offset     | Original             | Patched
-------------------------------- | :--------: | -------------------- | --
Initial License Check            | 0x0009D527 | 55 48 89 E5          | 48 31 C0 C3
Persistent License Check 1       | 0x000097F5 | E8 AE 12 13 00       | 90 90 90 90 90
Persistent License Check 2       | 0x0000980D | E8 96 12 13 00       | 90 90 90 90 90
Disable Server Validation Thread | 0x0009EA9D | 55 48 89 E5 41 57 41 | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x0009D122 | 55                   | C3
<!--  Disable Crash Reporter           | 0x00002A27 | 55                   | C3-->

##### Bash Script

```bash
# for MacOS
cd "/Applications/Sublime Text.app/Contents/MacOS/" || exit
md5 -q sublime_text | grep -i "E1A3347BECDA7CC1EF583ECACECACBDC" || exit
echo 0009D527: 48 31 C0 C3          | xxd -r - sublime_text
echo 000097F5: 90 90 90 90 90       | xxd -r - sublime_text
echo 0000980D: 90 90 90 90 90       | xxd -r - sublime_text
echo 0009EA9D: 48 31 C0 48 FF C0 C3 | xxd -r - sublime_text
echo 0009D122: C3                   | xxd -r - sublime_text
```

##### Re-Sign App

```bash
codesign --force --deep --sign - "/Applications/Sublime Text.app"
```

> Requires `Apple Command Line Tools` to be installed

#### <div id="ST_DC_macOS_ARM64">macOS (ARM64)</div>

> Based on: https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3929427#gistcomment-3929427

Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ------------------------| --
Initial License Check            | 0x010758B8 | FC 6F BA A9 E6 03 1E AA | E0 03 1F AA C0 03 5F D6
Persistent License Check 1       | 0x01000360 | 33 A4 03 94             | 1F 20 03 D5
Persistent License Check 2       | 0x01000374 | 2E A4 03 94             | 1F 20 03 D5
Disable Server Validation Thread | 0x01076B54 | F6 57 BD A9             | C0 03 5F D6
Disable License Notify Thread    | 0x01075534 | FC 6F BD A9             | C0 03 5F D6
<!--  Disable Crash Reporter           | 0x00FE6764 | FC 6F BC A9             | C0 03 5F D6-->

##### Bash Script

```bash
# for macOS (ARM64)
cd "/Applications/Sublime Text.app/Contents/MacOS/" || exit
md5 -q sublime_text | grep -i "E1A3347BECDA7CC1EF583ECACECACBDC" || exit
echo 010758B8: E0 03 1F AA C0 03 5F D6 | xxd -r - sublime_text
echo 01000360: 1F 20 03 D5             | xxd -r - sublime_text
echo 01000374: 1F 20 03 D5             | xxd -r - sublime_text
echo 01076B54: C0 03 5F D6             | xxd -r - sublime_text
echo 01075534: C0 03 5F D6             | xxd -r - sublime_text
```

##### Re-Sign App

```bash
codesign --force --deep --sign - "/Applications/Sublime Text.app"
```

> Requires `Apple Command Line Tools` to be installed

------------------------------------------------------------------------------

### How to Crack Sublime Merge, Stable Channel, Build 2083

Thanks to [**@leogx9r**](https://gist.github.com/leogx9r) for providing cracking methods.
> https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3823090#gistcomment-3823090
> https://gist.github.com/JerryLokjianming/71dac05f27f8c96ad1c8941b88030451?permalink_comment_id=3762883#gistcomment-3762883
> https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3802197#gistcomment-3802197

#### <div id="SM_SC_Win64">Win64</div>

Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ----------------------- | --
Initial License Check            | 0x000251A8 | 55 41 57 41 56 41 55 41 | 48 C7 C0 19 01 00 00 C3
Persistent License Check 1       | 0x000286A3 | E8 70 AA 26 00          | 90 90 90 90 90
Persistent License Check 2       | 0x000286BC | E8 57 AA 26 00          | 90 90 90 90 90
Disable Server Validation Thread | 0x000269B8 | 55 56 57 48 83 EC 30    | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x00024DCD | 55                      | C3
Disable Crash Reporter           | 0x00023F18 | 41                      | C3

##### Bat Script

```bat
:: for Win64
cd /d "C:\Program Files\Sublime Merge" || exit
certutil -hashfile sublime_merge.exe md5 | find /i "E33B76ADA6E7E7577CD4E81A7A4580C7" || exit
echo 000251A8: 48 C7 C0 19 01 00 00 C3 | xxd -r - sublime_merge.exe
echo 000286A3: 90 90 90 90 90          | xxd -r - sublime_merge.exe
echo 000286BC: 90 90 90 90 90          | xxd -r - sublime_merge.exe
echo 000269B8: 48 31 C0 48 FF C0 C3    | xxd -r - sublime_merge.exe
echo 00024DCD: C3                      | xxd -r - sublime_merge.exe
echo 00023F18: C3                      | xxd -r - sublime_merge.exe
```

PS：[**xxd.exe**](https://github.com/git-for-windows/git-sdk-64/raw/main/usr/bin/xxd.exe) extracted from [git for windows](https://github.com/git-for-windows/git-sdk-64)

#### <div id="SM_SC_Linux">Linux</div>
thinks @urxi [here](https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=4621995#gistcomment-4621995)

<!--Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ----------------------- | --
Initial License Check            | 0x0045A360 | 55 41 57 41             | 48 31 C0 C3
Persistent License Check 1       | 0x0045D21D | E8 1C 9E 16 00          | 90 90 90 90 90
Persistent License Check 2       | 0x0045D23A | E8 7E D8 1D 00          | 90 90 90 90 90
Disable Server Validation Thread | 0x0045B990 | 55 41 56 53 41 89 F6    | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x0045A05A | 41                      | C3
Disable Crash Reporter           | 0x00459ABA | 55                      | C3-->

##### Bash Script

```bash
# for Linux
cd /opt/sublime_merge || exit
md5sum -c <<<"86F61A82E7EE8DD9BDC4CF16A7C8E825  sublime_merge" || exit
echo 0045A360: 48 C7 C0 19 01 00 00 C3 | xxd -r - sublime_merge
echo 0045D21D: 90 90 90 90 90          | xxd -r - sublime_merge
echo 0045D23A: 90 90 90 90 90          | xxd -r - sublime_merge
echo 0045B990: C3                      | xxd -r - sublime_merge
echo 0045A05A: C3                      | xxd -r - sublime_merge
echo 00459ABA: C3                      | xxd -r - sublime_merge
```

#### <div id="SM_SC_macOS">macOS</div>

Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ----------------------- | --
Initial License Check            | 0x0002C2DF | 55 48 89 E5 41 57 41 56 | 48 C7 C0 19 01 00 00 C3
Persistent License Check 1       | 0x0002E96C | E8 1F B9 18 00          | 90 90 90 90 90
Persistent License Check 2       | 0x0002E98B | E8 00 B9 18 00          | 90 90 90 90 90
Disable Server Validation Thread | 0x0002D295 | 55 48 89 E5 41 57 41    | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x0002BF6A | 55                      | C3
Disable Crash Reporter           | 0x0002B7AB | 55                      | C3

##### Bash Script

```bash
# for MacOS
cd "/Applications/Sublime Merge.app/Contents/MacOS/" || exit
md5 -q sublime_merge | grep -i "B1AADED4F196EEEEBF8D5A6F98B11288" || exit
echo 0002C2DF: 48 C7 C0 19 01 00 00 C3 | xxd -r - sublime_merge
echo 0002E96C: 90 90 90 90 90          | xxd -r - sublime_merge
echo 0002E98B: 90 90 90 90 90          | xxd -r - sublime_merge
echo 0002D295: 48 31 C0 48 FF C0 C3    | xxd -r - sublime_merge
echo 0002BF6A: C3                      | xxd -r - sublime_merge
echo 0002B7AB: C3                      | xxd -r - sublime_merge
```

##### Re-Sign App

```bash
codesign --force --deep --sign - "/Applications/Sublime Merge.app"
```

> Requires `Apple Command Line Tools` to be installed

#### <div id="SM_SC_macOS_ARM64">macOS (ARM64)</div>

***!!!! May have expired !!!!***

Based on:
- https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3929427#gistcomment-3929427
- for ≥ 2075: https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=4311375#gistcomment-4311375

Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ----------------------- | --
Initial License Check            | 0x014D9060 | FC 6F BA A9 E6 03 1E AA | E0 03 1F AA C0 03 5F D6
Persistent License Check 1       | 0x014DAF68 | AB B6 04 94             | 1F 20 03 D5
Persistent License Check 2       | 0x014DAF7C | A6 B6 04 94             | 1F 20 03 D5
Disable Server Validation Thread | 0x014D9DBC | F6 57 BD A9             | C0 03 5F D6
Disable License Notify Thread    | 0x014D8D9C | FC 6F BD A9             | C0 03 5F D6
Disable Crash Reporter           | 0x014D86E4 | FC 6F BC A9             | C0 03 5F D6

##### Bash Script

```bash
# for macOS (ARM64)
cd "/Applications/Sublime Merge.app/Contents/MacOS/" || exit
md5 -q sublime_merge | grep -i "B1AADED4F196EEEEBF8D5A6F98B11288" || exit
echo 014D9060: E0 03 1F AA C0 03 5F D6 | xxd -r - sublime_merge
echo 014DAF68: 1F 20 03 D5             | xxd -r - sublime_merge
echo 014DAF7C: 1F 20 03 D5             | xxd -r - sublime_merge
echo 014D9DBC: C0 03 5F D6             | xxd -r - sublime_merge
echo 014D8D9C: C0 03 5F D6             | xxd -r - sublime_merge
echo 014D86E4: C0 03 5F D6             | xxd -r - sublime_merge
```

##### Re-Sign App

```bash
codesign --force --deep --sign - "/Applications/Sublime Merge.app"
```

> Requires `Apple Command Line Tools` to be installed

---

### How to Crack Sublime Merge, Dev Channel, Build 2085

Thanks to [**@leogx9r**](https://gist.github.com/leogx9r) for providing cracking methods.
> https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3823090#gistcomment-3823090
> https://gist.github.com/JerryLokjianming/71dac05f27f8c96ad1c8941b88030451?permalink_comment_id=3762883#gistcomment-3762883
> https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3802197#gistcomment-3802197

#### <div id="SM_DC_Win64">Win64</div>

Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ----------------------- | --
Initial License Check            | 0x00025300 | 55 41 57 41 56 41 55 41 | 48 C7 C0 19 01 00 00 C3
Persistent License Check 1       | 0x00028813 | E8 B8 7F 27 00          | 90 90 90 90 90
Persistent License Check 2       | 0x0002882C | E8 9F 7F 27 00          | 90 90 90 90 90
Disable Server Validation Thread | 0x00026B20 | 55 56 57 48 83 EC 30    | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x00024F25 | 55                      | C3
Disable Crash Reporter           | 0x00024070 | 41                      | C3

##### Bat Script

```bat
:: for Win64
cd /d "C:\Program Files\Sublime Merge" || exit
certutil -hashfile sublime_merge.exe md5 | find /i "8B6590708E6AAE98AC3AE29135DB084F" || exit
echo 00025300: 48 C7 C0 19 01 00 00 C3 | xxd -r - sublime_merge.exe
echo 00028813: 90 90 90 90 90          | xxd -r - sublime_merge.exe
echo 0002882C: 90 90 90 90 90          | xxd -r - sublime_merge.exe
echo 00026B20: 48 31 C0 48 FF C0 C3    | xxd -r - sublime_merge.exe
echo 00024F25: C3                      | xxd -r - sublime_merge.exe
echo 00024070: C3                      | xxd -r - sublime_merge.exe
```

PS：[**xxd.exe**](https://github.com/git-for-windows/git-sdk-64/raw/main/usr/bin/xxd.exe) extracted from [git for windows](https://github.com/git-for-windows/git-sdk-64)

#### <div id="SM_DC_Linux">Linux</div>
thinks @urxi [here](https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=4621995#gistcomment-4621995)

<!--
Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ----------------------- | --
  Initial License Check            | 0x003CF4F0 | 55 41 57 41             | 48 31 C0 C3
Persistent License Check 1       | 0x004620F9 | E8 56 1E 1E 00          | 90 90 90 90 90
  Persistent License Check 2       | 0x003D2519 | E8 40 1E 1E 00          | 90 90 90 90 90
Disable Server Validation Thread | 0x0046086C | 55 41 56 53 41 89 F6    | 48 31 C0 48 FF C0 C3
  Disable License Notify Thread    | 0x003CF208 | 41                      | C3
Disable Crash Reporter           | 0x0045E986 | 55                      | C3-->

##### Bash Script

```bash
# for Linux
cd /opt/sublime_merge || exit
md5sum -c <<<"958DA6B7EC687B25F55A16FF6A3D9BD0  sublime_merge" || exit
echo 0045F22C: 48 C7 C0 19 01 00 00 C3 | xxd -r - sublime_merge
echo 004620F9: 90 90 90 90 90          | xxd -r - sublime_merge
echo 00462116: 90 90 90 90 90          | xxd -r - sublime_merge
echo 0046086C: C3                      | xxd -r - sublime_merge
echo 0045EF26: C3                      | xxd -r - sublime_merge
echo 0045E986: C3                      | xxd -r - sublime_merge
```

#### <div id="SM_DC_macOS">macOS</div>

Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ----------------------- | --
Initial License Check            | 0x0002C4CB | 55 48 89 E5 41 57 41 56 | 48 C7 C0 19 01 00 00 C3
Persistent License Check 1       | 0x0002EB48 | E8 15 23 19 00          | 90 90 90 90 90
Persistent License Check 2       | 0x0002EB67 | E8 F6 22 19 00          | 90 90 90 90 90
Disable Server Validation Thread | 0x0002D471 | 55 48 89 E5 41 57 41    | 48 31 C0 48 FF C0 C3
Disable License Notify Thread    | 0x0002C156 | 55                      | C3
Disable Crash Reporter           | 0x0002B997 | 55                      | C3

##### Bash Script

```bash
# for MacOS
cd "/Applications/Sublime Merge.app/Contents/MacOS/" || exit
md5 -q sublime_merge | grep -i "D67510219FB14938A47BE39260C87215" || exit
echo 0002C4CB: 48 C7 C0 19 01 00 00 C3 | xxd -r - sublime_merge
echo 0002EB48: 90 90 90 90 90          | xxd -r - sublime_merge
echo 0002EB67: 90 90 90 90 90          | xxd -r - sublime_merge
echo 0002D471: 48 31 C0 48 FF C0 C3    | xxd -r - sublime_merge
echo 0002C156: C3                      | xxd -r - sublime_merge
echo 0002B997: C3                      | xxd -r - sublime_merge
```

##### Re-Sign App

```bash
codesign --force --deep --sign - "/Applications/Sublime Merge.app"
```

> Requires `Apple Command Line Tools` to be installed

#### <div id="SM_DC_macOS_ARM64">macOS (ARM64)</div>

***!!!! May have expired !!!!***

Based on:
- https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=3929427#gistcomment-3929427
- for ≥ 2075: https://gist.github.com/maboloshi/feaa63c35f4c2baab24c9aaf9b3f4e47?permalink_comment_id=4311375#gistcomment-4311375

Desciption                       | Offset     | Original                | Patched
-------------------------------- | :--------: | ----------------------- | --
Initial License Check            | 0x015027EC | FC 6F BA A9 E6 03 1E AA | E0 03 1F AA C0 03 5F D6
Persistent License Check 1       | 0x015046D4 | 78 C9 04 94             | 1F 20 03 D5
Persistent License Check 2       | 0x015046E8 | 73 C9 04 94             | 1F 20 03 D5
Disable Server Validation Thread | 0x0150352C | F6 57 BD A9             | C0 03 5F D6
Disable License Notify Thread    | 0x01502528 | FC 6F BD A9             | C0 03 5F D6
Disable Crash Reporter           | 0x01501E70 | FC 6F BC A9             | C0 03 5F D6

##### Bash Script

```bash
# for macOS (ARM64)
cd "/Applications/Sublime Merge.app/Contents/MacOS/" || exit
md5 -q sublime_merge | grep -i "D67510219FB14938A47BE39260C87215" || exit
echo 015027EC: E0 03 1F AA C0 03 5F D6 | xxd -r - sublime_merge
echo 015046D4: 1F 20 03 D5             | xxd -r - sublime_merge
echo 015046E8: 1F 20 03 D5             | xxd -r - sublime_merge
echo 0150352C: C0 03 5F D6             | xxd -r - sublime_merge
echo 01502528: C0 03 5F D6             | xxd -r - sublime_merge
echo 01501E70: C0 03 5F D6             | xxd -r - sublime_merge
```

##### Re-Sign App

```bash
codesign --force --deep --sign - "/Applications/Sublime Merge.app"
```

> Requires `Apple Command Line Tools` to be installed
