#if !defined(COMMON_H)
#define COMMON_H

/*
 * Brian Chrzanowski
 * Thu Jan 16, 2020 16:01
 *
 * Common Module for dbtool
 *
 * TODO (cleanup)
 * 1. Make a common module prefix (c_), and prepend it to common functions
 * 2. Reorganize the #defines in this header file
 */

#include <stdio.h>

#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

#include <assert.h>

#define SWAP(x, y, T) do { T SWAP = x; x = y; y = SWAP; } while (0)
#define IDX2D(x, y, ylen) ((x) + (y) * (ylen))
	
#define ARRSIZE(x)   (sizeof((x))/sizeof((x)[0]))

// some fun macros for variadic functions :^)
#define PP_ARG_N( \
          _1,  _2,  _3,  _4,  _5,  _6,  _7,  _8,  _9, _10, \
         _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, \
         _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, \
         _31, _32, _33, _34, _35, _36, _37, _38, _39, _40, \
         _41, _42, _43, _44, _45, _46, _47, _48, _49, _50, \
         _51, _52, _53, _54, _55, _56, _57, _58, _59, _60, \
         _61, _62, _63, N, ...) N

#define PP_RSEQ_N()                                        \
         63, 62, 61, 60,                                   \
         59, 58, 57, 56, 55, 54, 53, 52, 51, 50,           \
         49, 48, 47, 46, 45, 44, 43, 42, 41, 40,           \
         39, 38, 37, 36, 35, 34, 33, 32, 31, 30,           \
         29, 28, 27, 26, 25, 24, 23, 22, 21, 20,           \
         19, 18, 17, 16, 15, 14, 13, 12, 11, 10,           \
          9,  8,  7,  6,  5,  4,  3,  2,  1,  0

#define PP_NARG_(...)    PP_ARG_N(__VA_ARGS__)
#define PP_NARG(...)     (sizeof(#__VA_ARGS__) - 1 ? PP_NARG_(__VA_ARGS__, PP_RSEQ_N()) : 0)

/* quick and dirty, cleaner typedefs */
typedef unsigned char      u8;
typedef unsigned short     u16;
typedef unsigned int       u32;
typedef unsigned long long u64;
typedef char               s8;
typedef short              s16;
typedef int                s32;
typedef long long          s64;
typedef float              f32;
typedef double             f64;

// the 128 bit typedefs somewhat rely on GCC and a REALLY modern machine...
// I'm tempted to not have these, but they really help with the numeric
// calculations
typedef __int128           s128;
typedef unsigned __int128  u128;

#define BUFSMALL (256)
#define BUFLARGE (4096)
#define BUFGIANT (1 << 20 << 1)

/* c_resize : resizes the ptr should length and capacity be the same */
void c_resize(void *ptr, size_t *len, size_t *cap, size_t bytes);

#define C_RESIZE(x,y,z) (c_resize((x),y##_len,y##_cap,z))

/* sql_fmtstr : formats an input string into the dst, sql ready */
int sql_fmtstr(char *dst, char *src, size_t dstlen);

// NOTE (brian) the regular expression functions were stolen from Rob Pike
/* regex : function to help save some typing */
int regex(char *text, char *regexp);
/* regex_match : search for regexp anywhere in text */
int regex_match (char *regexp, char *text);
/* regex_matchhere: search for regexp at beginning of text */
int regex_matchhere(char *regexp, char *text);
/* regex_matchstar: search for c*regexp at beginning of text */
int regex_matchstar(int c, char *regexp, char *text);

/* strsplit : string split */
size_t strsplit(char **arr, size_t len, char *buf, char sep);
/* strlen_char : returns strlen, but as if 'c' were the string terminator */
size_t strlen_char(char *s, char c);
/* bstrtok : Brian's (Better) strtok */
char *bstrtok(char **str, char *delim);
/* strnullcmp : compare strings, sorting null values as "first" */
int strnullcmp(const void *a, const void *b);
/* strornull : returns the string representation of NULL if the string is */
char *strornull(char *s);

/* c_readfile : reads an entire file into a memory buffer */
char *c_readfile(char *path);

/* mkguid : puts a guid in the buffer if it's long enough */
int mkguid(char *buf, size_t len);

/* ltrim : removes whitespace on the "left" (start) of the string */
char *ltrim(char *s);

/* rtrim : removes whitespace on the "right" (end) of the string */
char *rtrim(char *s);

/* mklower : makes the string lower cased */
int mklower(char *s);

/* mkupper : makes the string lower cased */
int mkupper(char *s);

/* streq : return true if the strings are equal */
int streq(char *s, char *t);

/* is_num : returns true if the string is numeric */
int is_num(char *s);

/* c_atoi : stdlib's atoi, but returns 0 if the pointer is NULL */
s32 c_atoi(char *s);

/* c_cmp_strstr : common comparator for two strings */
int c_cmp_strstr(const void *a, const void *b);

/* strdup_null : duplicates the string if non-null, returns NULL otherwise */
char *strdup_null(char *s);

/* c_fprintf : common printf logging routine, with some extra pizzaz */
int c_fprintf(char *file, int line, int level, FILE *fp, char *fmt, ...);

enum {
	  LOG_NON
	, LOG_ERR
	, LOG_WRN
	, LOG_MSG
	, LOG_VER
	, LOG_TOTAL
};

// TODO (brian) see if we can use a base macro to make this cleaner/nicer
// TODO (brian) should all of these log to stderr? Yes, if stdout is really output... (should it be?)
#define LOG(fmt, ...) (c_fprintf(__FILE__, __LINE__, LOG_LOG, stderr, fmt, ##__VA_ARGS__)) // basic log message
#define MSG(fmt, ...) (c_fprintf(__FILE__, __LINE__, LOG_MSG, stderr, fmt, ##__VA_ARGS__)) // basic log message
#define WRN(fmt, ...) (c_fprintf(__FILE__, __LINE__, LOG_WRN, stderr, fmt, ##__VA_ARGS__)) // warning message
#define ERR(fmt, ...) (c_fprintf(__FILE__, __LINE__, LOG_ERR, stderr, fmt, ##__VA_ARGS__)) // error message
#define VER(fmt, ...) (c_fprintf(__FILE__, __LINE__, LOG_VER, stderr, fmt, ##__VA_ARGS__)) // verbose message

#endif // COMMON_H

