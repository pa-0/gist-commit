/*
 * Wed Mar 25, 2020 13:29
 *
 * Set the Windows Clipboard Type from the Content
 * -t <type>
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include <ctype.h>

// #define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include "common.h"

/* make_html : formats the html string, so it's suitable for win32's clipboard system */
s32 make_html(char **s, size_t *slen);

/* clip_yank : copy at most, len bytes from the clipboard into s */
s32 clip_yank(char *s, size_t slen, s32 type);
/* clip_paste : copy len bytes from s into the clipboard */
s32 clip_paste(char *s, size_t slen, s32 type);
/* clip_getformat : gets the clipboard format */
s32 clip_getformat(char *s);
/* clip_open : returns true if we opened the clipboard */
s32 clip_open();
/* clip_close : returns true if we closed the clipboard */
s32 clip_close();
/* clip_clear() : clear the clipboard */
s32 clip_clear();

void CopyHTML(char *html);

int main(int argc, char **argv)
{
	char *s;
	size_t sbuf_len, sbuf_cap;
	s32 clipboard_format;
	s32 ret;
	char buf[BUFSMALL];

	s = NULL;
	sbuf_len = sbuf_cap = 0;

	// read from stdin
	while (buf == fgets(buf, sizeof buf, stdin)) {
		c_resize(&s, &sbuf_len, &sbuf_cap, sizeof(char));
		strncpy(s + sbuf_len, buf, sbuf_cap - sbuf_len);
		sbuf_len = strlen(s);
	}

#if 1
	char *html = "<b>testing, one two three</b>";
	CopyHTML(html);
#else
	make_html(&s, &sbuf_len);

	printf("Copying...\n%s\n", s);

	clip_open();
	clip_clear();

	clipboard_format = clip_getformat("HTML Format");

	// copy it to the windows clipboard
	ret = clip_paste(s, sbuf_len, clipboard_format);
	if (ret < 0) {
		ERR("Couldn't paste to the clipboard: %d\n", GetLastError());
	}

	clip_close();
#endif

	free(s);

	return 0;
}

/* make_html : formats the html string, so it's suitable for win32's clipboard system */
s32 make_html(char **s, size_t *slen)
{
	char *fmt;
	char *content;
	char *off;
	size_t headerlen;
	char buf[BUFSMALL];

	size_t html_start, html_end, frag_start, frag_end;

	fmt = "Version:0.9\nStartHTML:%012d\nEndHTML:%012d\nStartFragment:%012d\nEndFragment:%012d\n%s";

	if (!(s && *s)) {
		return -1;
	}

	content = strdup(*s);
	free(*s);
	*slen = 0;

	*s = calloc(1, BUFGIANT);

	// print zeros to get printf to tell us how big the header is
	// (keep in mind Win32CRT Auto Formatting Nonsense)
	snprintf(buf, sizeof buf, fmt, 0, 0, 0, 0, "");
	headerlen = strlen(buf);

	// finding the html offsets is a little less involved
	html_start = strstr(content, "<html>") - content;
	html_end = strlen(content);

	frag_start = strstr(content, "<!--StartFragment-->") - content;
	frag_end = strstr(content, "<!--EndFragment-->") - content;

	// now, update all of the values to be offset from the end of the header
	html_start += headerlen;
	html_end += headerlen;
	frag_start += headerlen;
	frag_end += headerlen;

	// now, we can print out the content and offsets, as needed
	*slen = snprintf(*s, BUFGIANT, fmt, html_start, html_end, frag_start, frag_end, content);

	printf("HTML Start Char : %c\n", (*s)[html_start]);
	printf("HTML End   Char : %c\n", (*s)[html_end]);
	printf("Frag Start Char : %c\n", (*s)[frag_start]);
	printf("Frag Ent   Char : %c\n", (*s)[frag_end]);

	free(content);

	return 0;
}

/* clip_yank : copy at most, len bytes from the clipboard into s */
s32 clip_yank(char *s, size_t slen, s32 type)
{
	char *t;

	t = GetClipboardData(type);

	if (t) {
		memset(s, 0, slen);
		strncpy(s, t, slen - 1);
	}

	return t != NULL ? 0 : -1;
}

/* clip_paste : copy len bytes from s into the clipboard */
s32 clip_paste(char *s, size_t slen, s32 type)
{
	HGLOBAL buffer;

	clip_clear();
	buffer = GlobalAlloc(GMEM_DDESHARE, slen);

	if (!buffer) {
		return -1;
	}

	memcpy(GlobalLock(buffer), s, slen);
	GlobalUnlock(buffer);

	return SetClipboardData(type, buffer) != NULL ? 0: -1;
}

/* clip_getformat : gets the clipboard format */
s32 clip_getformat(char *s)
{
	return RegisterClipboardFormat(s);
}

/* clip_open : returns true if we opened the clipboard */
s32 clip_open()
{
	return OpenClipboard(NULL) != 0 ? 1 : 0;
}

/* clip_close : returns true if we closed the clipboard */
s32 clip_close()
{
	return CloseClipboard() != 0 ? 1 : 0;
}

/* clip_clear() : clear the clipboard */
s32 clip_clear()
{
	return EmptyClipboard();
}

s32 help()
{
	return 0;
}

// CopyHtml() - Copies given HTML to the clipboard.
// The HTML/BODY blanket is provided, so you only need to
// call it like CallHtml("<b>This is a test</b>");
void CopyHTML(char *html)
{
    // Create temporary buffer for HTML header...
    char *buf = calloc(1, 400 + strlen(html));
    if(!buf) return;

    // Get clipboard id for HTML format...
    int cfid;
	cfid = RegisterClipboardFormat("HTML Format");

    // Create a template string for the HTML header...
    strcpy(buf,
        "Version:0.9\r\n"
        "StartHTML:00000000\r\n"
        "EndHTML:00000000\r\n"
        "StartFragment:00000000\r\n"
        "EndFragment:00000000\r\n"
        "<html><body>\r\n"
        "<!--StartFragment -->\r\n");

    // Append the HTML...
    strcat(buf, html);
    strcat(buf, "\r\n");
    // Finish up the HTML format...
    strcat(buf,
        "<!--EndFragment-->\r\n"
        "</body>\r\n"
        "</html>");

    // Now go back, calculate all the lengths, and write out the
    // necessary header information. Note, wsprintf() truncates the
    // string when you overwrite it so you follow up with code to replace
    // the 0 appended at the end with a '\r'...
    char *ptr = strstr(buf, "StartHTML");
    wsprintf(ptr+10, "%08u", strstr(buf, "<html>") - buf);
    *(ptr+10+8) = '\r';

    ptr = strstr(buf, "EndHTML");
    wsprintf(ptr+8, "%08u", strlen(buf));
    *(ptr+8+8) = '\r';

    ptr = strstr(buf, "StartFragment");
    wsprintf(ptr+14, "%08u", strstr(buf, "<!--StartFrag") - buf);
    *(ptr+14+8) = '\r';

    ptr = strstr(buf, "EndFragment");
    wsprintf(ptr+12, "%08u", strstr(buf, "<!--EndFrag") - buf + strlen("<!--EndFrag-->"));
    *(ptr+12+8) = '\r';

    // Now you have everything in place ready to put on the
    // clipboard.

    // Open the clipboard...
    if(OpenClipboard(0)) {
        
        // Empty what's in there...
        EmptyClipboard();
        
        // Allocate global memory for transfer...
        HGLOBAL hText = GlobalAlloc(GMEM_MOVEABLE |GMEM_DDESHARE, strlen(buf));
        
        // Put your string in the global memory...
        char *ptr = (char *)GlobalLock(hText);
        strcpy(ptr, buf);
        GlobalUnlock(hText);
        
        SetClipboardData(cfid, hText);
        
        CloseClipboard();
        // Free memory...
        GlobalFree(hText);
    } else {
		ERR("Couldn't open the clipboard: %d\n", GetLastError());
	}

	free(buf);
}


/*
 * Brian Chrzanowski
 * Mon Jan 13, 2020 14:50
 *
 * Common C Functions
 *
 * TODO (cleanup)
 * 1. Organize these functions, and their position in .c and .h files
 */

#include <stdio.h>

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

#include "common.h"

/* c_resize : resizes the ptr should length and capacity be the same */
void c_resize(void *ptr, size_t *len, size_t *cap, size_t bytes)
{
	void **p;

	if (*len == *cap) {
		p = (void **)ptr;

		if (*cap) {
			if (BUFLARGE < *cap) {
				*cap += BUFLARGE;
			} else {
				*cap *= 2;
			}
		} else {
			*cap = BUFSMALL;
		}

		*p = realloc(*p, bytes * *cap);

		// set the rest of the elements to zero
		memset(((u8 *)*p) + *len * bytes, 0, (*cap - *len) * bytes);
	}
}

/* ltrim : removes whitespace on the "left" (start) of the string */
char *ltrim(char *s)
{
	while (isspace(*s))
		s++;

	return s;
}

/* rtrim : removes whitespace on the "right" (end) of the string */
char *rtrim(char *s)
{
	char *e;

	for (e = s + strlen(s) - 1; isspace(*e); e--)
		*e = 0;

	return s;
}

/* strnullcmp : compare strings, sorting null values as "first" */
int strnullcmp(const void *a, const void *b)
{
	char **stra, **strb;

	stra = (char **)a;
	strb = (char **)b;

	if (*stra == NULL && *strb == NULL) {
		return 0;
	}

	if (*stra == NULL && *strb != NULL) {
		return 1;
	}

	if (*stra != NULL && *strb == NULL) {
		return -1;
	}

	return strcmp(*stra, *strb);
}

/* strornull : returns the string representation of NULL if the string is */
char *strornull(char *s)
{
	// NOTE also returns NULL on empty string
	return (s && strlen(s) != 0) ? s : "NULL";
}

/* strcmpv : a qsort wrapper for strcmp */
int strcmpv(const void *a, const void *b)
{
	// remember, we get char **s
	return (int)strcmp(*(char **)a, *(char **)b);
}

/* regex : function to help save some typing */
int regex(char *text, char *regexp)
{
	return regex_match(regexp, text);
}

/* regex_match : search for regexp anywhere in text */
int regex_match(char *regexp, char *text)
{
	if (regexp[0] == '^')
		return regex_matchhere(regexp+1, text);
	do {    /* must look even if string is empty */
		if (regex_matchhere(regexp, text))
			return 1;
	} while (*text++ != '\0');
	return 0;
}

/* regex_matchhere: search for regexp at beginning of text */
int regex_matchhere(char *regexp, char *text)
{
	if (regexp[0] == '\0')
		return 1;
	if (regexp[1] == '*')
		return regex_matchstar(regexp[0], regexp+2, text);
	if (regexp[0] == '$' && regexp[1] == '\0')
		return *text == '\0';
	if (*text!='\0' && (regexp[0]=='.' || regexp[0]==*text))
		return regex_matchhere(regexp+1, text+1);
	return 0;
}

/* regex_matchstar: search for c*regexp at beginning of text */
int regex_matchstar(int c, char *regexp, char *text)
{
	do {    /* a * matches zero or more instances */
		if (regex_matchhere(regexp, text))
			return 1;
	} while (*text != '\0' && (*text++ == c || c == '.'));
	return 0;
}

/* strsplit : string split */
size_t strsplit(char **arr, size_t len, char *buf, char sep)
{
	size_t num, i;
	char *s;


	// first, we count how many instances of sep there are
	// then we split it into that many pieces

	for (num = 0, s = buf; *s; s++) {
		if (*s == sep) {
			num++;
		}
	}

	if (arr) { // only if we have a valid array, do we actually split the str
		memset(arr, 0, len * sizeof(*arr));
		for (i = 0, s = buf; i < len; i++) {
			if (0 < strlen_char(s, sep)) {
				arr[i] = s;

				s = strchr(s, sep);
				if (s == NULL)
					break;
			} else {
				arr[i] = s + strlen(s); // empty string, point to NULL byte
			}

			*s = 0;
			s++;
		}
	}

	return num;
}

/* strlen_char : returns strlen, but as if 'c' were the string terminator */
size_t strlen_char(char *s, char c)
{
	size_t i;

	// NOTE this will stop at NULLs

	for (i = 0; s[i]; i++)
		if (s[i] == c)
			break;

	return i;
}

/* bstrtok : Brian's (Better) strtok */
char *bstrtok(char **str, char *delim)
{
	/*
	 * strtok is super gross. let's make it better (and worse)
	 *
	 * few things to note
	 *
	 * To use this properly, pass a pointer to your buffer as well as a string
	 * you'd like to delimit your text by. When you've done that, you
	 * effectively have two return values. The NULL terminated C string
	 * explicitly returned from the function, and the **str argument will point
	 * to the next section of the buffer to parse. If str is ever NULL after a
	 * call to this, there is no new delimiting string, and you've reached the
	 * end
	 */

	char *ret, *work;

	ret = *str; /* setup our clean return value */
	work = strstr(*str, delim); /* now do the heavy lifting */

	if (work) {
		/* we ASSUME that str was originally NULL terminated */
		memset(work, 0, strlen(delim));
		work += strlen(delim);
	}

	*str = work; /* setting this will make *str NULL if a delimiter wasn't found */

	return ret;
}

/* c_readfile : reads an entire file into a memory buffer */
char *c_readfile(char *path)
{
	FILE *fp;
	s64 size;
	char *buf;

	fp = fopen(path, "r");
	if (!fp) {
		return NULL;
	}

	// get the file's size
	fseek(fp, 0, SEEK_END);
	size = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	buf = malloc(size + 1);
	memset(buf, 0, size + 1);

	fread(buf, 1, size, fp);
	fclose(fp);

	return buf;
}

/* streq : return true if the strings are equal */
int streq(char *s, char *t)
{
	return strcmp(s, t) == 0;
}

/* is_num : returns true if the string is numeric */
int is_num(char *s)
{
	while (s && *s) {
		if (!isdigit(*s))
			return 0;
	}

	return 1;
}

/* c_atoi : stdlib's atoi, but returns 0 if the pointer is NULL */
s32 c_atoi(char *s)
{
	return s == NULL ? 0 : atoi(s);
}

/* mklower : makes the string lower cased */
int mklower(char *s)
{
	char *t;
	for (t = s; *t; t++) {
		*t = tolower(*t);
	}
	return 0;
}

/* mkupper : makes the string lower cased */
int mkupper(char *s)
{
	char *t;
	for (t = s; *t; t++) {
		*t = toupper(*t);
	}
	return 0;
}

/* c_cmp_strstr : common comparator for two strings */
int c_cmp_strstr(const void *a, const void *b)
{
	char *stra, *strb;

	// generic strcmp, with NULL checks

	stra = *(char **)a;
	strb = *(char **)b;

	if (stra == NULL && strb != NULL)
		return 1;

	if (stra != NULL && strb == NULL)
		return -1;

	if (stra == NULL && strb == NULL)
		return 0;

	return strcmp(stra, strb);
}

/* strdup_null : duplicates the string if non-null, returns NULL otherwise */
char *strdup_null(char *s)
{
	return s ? strdup(s) : NULL;
}

/* c_fprintf : common printf logging routine, with some extra pizzaz */
int c_fprintf(char *file, int line, int level, FILE *fp, char *fmt, ...)
{
	va_list args;
	int rc;
	char bigbuf[BUFLARGE];

	char *logstr[] = {
		  "   " // LOG_NON = 0 (this is a special case, to make the array work)
		, "ERR" // LOG_ERR = 1
		, "WRN" // LOG_WRN = 2
		, "MSG" // LOG_MSG = 3
		, "VER" // LOG_VER = 4
	};

	// NOTE (brian)
	//
	// This writes a formatted message:
	//   __FILE__:__LINE__ LEVELSTR MESSAGE

	assert(LOG_TOTAL == ARRSIZE(logstr));

	if (!(LOG_NON <= level && level <= LOG_VER)) {
		WRN("Invalid LOG Level from %s:%d\n", file, line);
		level = LOG_NON;
	}

	rc = 0;

	if (strlen(fmt) == 0)
		return rc;

	memset(bigbuf, 0, sizeof(bigbuf));

	va_start(args, fmt); /* get the arguments from the stack */

	rc += fprintf(fp, "%s:%-4d %s ", file, line, logstr[level]);
	rc += vfprintf(fp, fmt, args);

	va_end(args); /* cleanup stack arguments */

	if (fmt[strlen(fmt) - 1] != '\n' && fmt[strlen(fmt) - 1] != '\r') {
		rc += fprintf(fp, "\n");
	}

	return rc;
}


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

