# pass bump to this build script to bump the script version
# Pass the arguments to the build script
node ./build_userscript.js "$@"
echo running prettier
prettier --write **/*.js

