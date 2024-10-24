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

