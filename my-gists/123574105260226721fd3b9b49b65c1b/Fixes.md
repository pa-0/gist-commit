# Nerd-Patcher Fixes for Input Mono

Below are all the possible fixes/workarounds I found for potential issues that might arise when attempting to apply the nerd-font patch to InputMono:

## [from gist Comments]

### Found success with:

-   clone the nerd-fonts repo
-   install fontforge via brew
-   `sudo easy_install pip` and `sudo pip install configparser` (I tried using python3 from brew, but that didn't work, so sticking with the system python)
-   ```bash
    for font in ~/Downloads/Input-Font/Input_Fonts/Input/*.ttf
      do
        fontforge -script ./font-patcher --careful --complete  --progressbars "$font"
      done
    ```    
    I get one minor warning from Font Book about the BoldItalic variation (`'name' table usability`), but it all seems to work nicely:
    [![screen shot 2018-03-05 at 10 20 43 pm](https://user-images.githubusercontent.com/166810/37014096-ec7fa93a-20c3-11e8-9d50-cbf47f721a71.png)](https://user-images.githubusercontent.com/166810/37014096-ec7fa93a-20c3-11e8-9d50-cbf47f721a71.png)


### You can also try adding:

`--adjust-line-height` to the list of patcher arguments. If you look closely, the Powerline separator isn't exactly the same height as the prompt. 

### One other issue if patched with `--complete` 

then letter _J_ would turn into an icon - excluding `--materialicons` flag solves the issue 

## [from Issue #400] Patching `InputMono` overwrites the letter `j` #400

### [CPWeaver](https://github.com/CPWeaver)** commented [on Oct 31, 2019](https://github.com/ryanoasis/nerd-fonts/issues/400#issue-515763736)

##### 🎯 Subject of the issue

I'm running font-patcher to patch InputMono font. If I use `--complete` then the icon  
`nf-mdi-decimal_increase` overwrites the letter `j`. If I do not include mdi in the patching than the letter `j` is unaffected.

##### 🔧 Your Setup

-   Which font are you using (e.g. `Anonymice Powerline Nerd Font Complete.ttf`)?_
InputMono, all variants. e.g. `InputMono-Medium.ttf`
-   _Which terminal emulator are you using (e.g. `iterm2`, `urxvt`, `gnome`, `konsole`)?_
iterm2 though this also shows up in the OSX Font Viewer
-   _Are you using OS X, Linux or Windows? And which specific version or distribution?_
OSX Catalina. It was true on Mavericks as well.

[![image](https://user-images.githubusercontent.com/4966467/67987759-d7f08680-fbf3-11e9-8544-2adef4aae273.png)](https://user-images.githubusercontent.com/4966467/67987759-d7f08680-fbf3-11e9-8544-2adef4aae273.png)

### [kmalinich](https://github.com/kmalinich)** commented [on Sep 4, 2020](https://github.com/ryanoasis/nerd-fonts/issues/400#issuecomment-687229777)

I had the same issue, and I tried every combination of dropping different command line arguments, but I couldn't get patching with all glyphs to work (without breaking the J character) ....... until I did it like this (a couple extra lines added for context).  Not really sure why this makes it work properly.

```shell
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts
cd nerd-fonts
mkdir -p ~/fonts/InputMonoCompressed/Patched/
find ~/fonts/InputMonoCompressed/ -maxdepth 1 -name '*.ttf' | parallel -j $(nproc) fontforge -script font-patcher --no-progressbars --careful --complete --outputdir ~/fonts/InputMonoCompressed/Patched/ {} \;
```
### [ayamir](https://github.com/ayamir)** commented [on Sep 11, 2020](https://github.com/ryanoasis/nerd-fonts/issues/400#issuecomment-691051187) • edited 

Thanks [@kmalinich](https://github.com/kmalinich) 


### [kmalinich](https://github.com/kmalinich)** commented [on Sep 11, 2020](https://github.com/ryanoasis/nerd-fonts/issues/400#issuecomment-691276459) • edited 

@MiraculousMoon Do you mean the height of the arrows? If so, you might try adding `--adjust-line-height` to the arguments. The `--help` states this:

```bash
 -l, --adjust-line-height
                        # Whether to adjust line heights (attempt to center powerline separators more evenly)
```


### [ayamir](https://github.com/ayamir)** commented [on Sep 12, 2020](https://github.com/ryanoasis/nerd-fonts/issues/400#issuecomment-691447775) • edited 

>@MiraculousMoon Do you mean the height of the arrows? If so, you might try adding `--adjust-line-height` to the arguments. The `--help` states this:
>
>```bash
>-l, --adjust-line-height
>                      # Whether to adjust line heights (attempt to center powerline separators more evenly)
>```

Thanks for your reply!  
This is my command:

```bash
find ~/Input_ori/ -maxdepth 1 -name '*.ttf' | parallel -j $(nproc ) fontforge -script font-patcher --no-progressbars --careful --complete --adjust-line-height --outputdir ~/input/ {} \;
```

### [dabekf](https://github.com/dabekf)** commented [on Aug 18, 2022](https://github.com/ryanoasis/nerd-fonts/issues/400#issuecomment-1219805335) • edited 

The original problem was "`nf-mdi-decimal_increase` overwrites the letter `j`". It's more than that. 'Decimal increase' is `U+F6BE` and Input Mono actually already has a character at that spot and it looks like a "dotlessj": ȷ. For some reason updating `U+F6BE` modifies other j-like characters, for example: `U+006A` j, `U+0237` ȷ, `U+0458` ј, maybe others.

The `'--careful'` fontpatcher option kind of works, it skips the problematic characters, but then few other existing glyphs don't get updated, like `U+E0B0` `nf-pl-left_hard_divider`. That might have been the cause of arrow defects in the screenshots - Input Mono's original versions are shifted up a bit.

Anyway, I don't really need the 'decimal increase' character, so I modified the fontpatcher to skip the three private characters Input Mono has around that range. The patch is for fontpatcher-2.2.0-RC but it probably works in other versions too.

```diff
*** font-patcher-orig   Wed Aug 17 23:51:55 2022
--- font-patcher-github Thu Aug 18 20:20:28 2022
*************** class font_patcher:
*** 688,693 ****
--- 688,698 ----
              # Prepare symbol glyph dimensions
              sym_dim = get_glyph_dimensions(sym_glyph)

+             # Input Mono tmp fix for weird 'j' and possibly other characters
+             if self.sourceFont.familyname.startswith("InputMono NF") and copiedToSlot in ['F6BE', 'F6C3', 'F8FF']:
+                 print("  Input Mono weird glyph at {}. Skipping...".format(copiedToSlot))
+                 continue
+
              # check if a glyph already exists in this location
              if careful or 'careful' in sym_attr['params']:
                  if copiedToSlot.startswith("uni"):
```
<br>
<br>

**_Edit:_** 

Here is the updated patch for version 2.2.1, some changes made the previous one incompatible:

```diff
*** font-patcher.orig	Fri Aug 26 23:58:07 2022
--- font-patcher.new	Mon Sep  5 23:39:47 2022
*************** class font_patcher:
*** 932,937 ****
--- 932,942 ----
                      sys.stdout.write(progressText)
                      sys.stdout.flush()
  
+             # Input Mono tmp fix for weird 'j' and possibly other characters
+             if self.sourceFont.familyname.startswith("InputMono NF") and "{:X}".format(currentSourceFontGlyph) in ['F6BE', 'F6C3', 'F8FF']:
+                 print("  Input Mono weird glyph at {:X}. Skipping...".format(currentSourceFontGlyph))
+                 continue
+ 
              # check if a glyph already exists in this location
              if careful or 'careful' in sym_attr['params']:
                  if currentSourceFontGlyph in self.sourceFont:
```


### [nathanielevan](https://github.com/nathanielevan)** commented [on Jan 19, 2023](https://github.com/ryanoasis/nerd-fonts/issues/400#issuecomment-1397371200) • edited 

This is what I've done to fix it (hopefully):

```diff
diff --git a/font-patcher b/font-patcher
index 0d542b4..2682391 100755
--- a/font-patcher
+++ b/font-patcher
@@ -904,6 +904,23 @@ class font_patcher:
             self.sourceFont.hhea_ascent = self.sourceFont.os2_winascent
             self.sourceFont.hhea_descent = -self.sourceFont.os2_windescent
 
+    def add_glyphrefs_to_essential(self, unicode):
+        self.essential.add(unicode)
+        # According to fontforge spec, altuni is either None or a tuple of tuples
+        if self.sourceFont[unicode].altuni is not None:
+            for r in self.sourceFont[unicode].altuni:
+                # If alternate unicode already exists in self.essential,
+                # that means it has gone through this function before.
+                # Therefore we skip it to avoid infinite loop.
+                # A unicode value of -1 basically means unused and is also worth skipping.
+                if r[0] in self.essential or r[0] == -1:
+                    continue
+                self.add_glyphrefs_to_essential(r[0])
+        for r in self.sourceFont[unicode].references:
+            if self.sourceFont[r[0]].unicode in self.essential or self.sourceFont[r[0]].unicode == -1:
+                continue
+            self.add_glyphrefs_to_essential(self.sourceFont[r[0]].unicode)
+
     def get_essential_references(self):
         """Find glyphs that are needed for the basic glyphs"""
         # Sometimes basic glyphs are constructed from multiple other glyphs.
@@ -913,8 +930,7 @@ class font_patcher:
         for glyph in range(0x21, 0x17f):
             if not glyph in self.sourceFont:
                 continue
-            for r in self.sourceFont[glyph].references:
-                self.essential.add(self.sourceFont[r[0]].unicode)
+            self.add_glyphrefs_to_essential(glyph)
 
     def get_sourcefont_dimensions(self):
         # Initial font dimensions
```
