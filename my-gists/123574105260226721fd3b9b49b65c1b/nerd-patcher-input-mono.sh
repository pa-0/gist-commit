## Creating this because I'm *sure* I'll forget how to do this.

# 1. Customize your Input fontface, and download it from their website:
open -a Safari \
   "http://input.fontbureau.com/download/index.html?size=14&language=javascript&theme=base16-dark&family=InputMono&width=200&weight=300&line-height=1.2&a=0&g=ss&i=serif&l=serifs_round&zero=slash&asterisk=height&braces=straight&preset=dejavu&customize=please"

# 2. Download the ‘patcher script’:
cd ~/Downloads/Input-Font
curl -o nerd-patcher.py -JO -fsSl --proto-redir -all,https \
   https://raw.githubusercontent.com/ryanoasis/nerd-fonts/1.0.0/{font-patcher,changelog.md}
svn checkout https://github.com/ryanoasis/nerd-fonts/branches/1.0.0/src/glyphs src/glyphs

# 3. Install the patcher-script's dependencies:
brew install fontforge

# 4. Patch the files:
for font in Input_Fonts/Input/*.ttf; do
   python nerd-patcher.py --careful --complete --progressbars "$font"; done

# 5. Install the patched fonts:
open -a 'Font Book' 'Input '*