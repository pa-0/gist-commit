module.exports = {
  config: {
    NUM_RETRIES_ON_EMPTY: 0,
    REMOVE_CLASSIC_DOWNLOAD_BUTTON: false,
    SUFFIX_STRATEGY: "LENGTH",
    SUFFIX_STRATEGY_LENGTH_LIMIT: 5,
    DISCARD_POSTERS_FILE_NAMES: false,
    SUFFIX_STRATEGY_MD5_LIMIT: 5
  },
  documentation: {
    NUM_RETRIES_ON_EMPTY: `How many times to retry if user enters an empty string`,
    REMOVE_CLASSIC_DOWNLOAD_BUTTON: `Turn this on to remove the classic download button and leave only the "Download As" button`,
    SUFFIX_STRATEGY: `
Decide on how to generate a suffix
LENGTH: uses the first n digits of the hexadecimal representation of the code
block's length
MD5: uses the first n characters of an md5 checksum(overkill)
    `,
    SUFFIX_STRATEGY_LENGTH_LIMIT: `
Limit the number of suffix characters for the length strategy.
Any number equal to 0 or less here will make the userscript use the entire
string
`,
    SUFFIX_STRATEGY_MD5_LIMIT: `
How many characters to take from the beginning of the md5 sum.
Any number equal to 0 or less here will make the userscript use the entire
string
`,
    DISCARD_POSTERS_FILE_NAMES: `
Sometimes, users will add legitimate names to the files. Turn this on if
you dont want to discard them
`
  },
  requires: []
};
