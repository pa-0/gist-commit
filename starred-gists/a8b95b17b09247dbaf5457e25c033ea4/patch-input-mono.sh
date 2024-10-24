# Just in case I forget how I did this;

# Download Input from https://input.djr.com/ (licensing restrictions)

# I ran into issues with the letter 'j'. `--complete` would completely bork that letter, adding `--careful` fixes it
# Some glyphs had an almost negligible amount of vertical misalignemnt, used `--adjust-line-height` but probably not necessary

# Clone nerdfonts, or copy paste the script under `font-patcher` and follow the instructions here:
# https://github.com/ryanoasis/nerd-fonts (there's a font-patcher section in the README)


# Or use the docker image
# (Example; unzipped and placed all .tff files under `/input-mono`)

docker run -v ~/input-mono:/in -v ~/patched-fonts:/out nerdfonts/patcher --careful --complete --adjust-line-height