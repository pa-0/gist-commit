#include "../compat.h"
#include <stdio.h>

// gcc -Dzpbpaste=main -DSTANDALONE

#if defined(_WIN32) || (!defined(__GNUC__) && !defined(__clang__))
	#include <windows.h>
	#include <winuser.h>
	#ifdef STANDALONE
		unsigned char buf[BUFLEN];
	#else
		#include "../cielbox.h"
	#endif
#else
	//use execvp()
	#include <unistd.h>
#endif

#if defined(_WIN32) || (!defined(__GNUC__) && !defined(__clang__))

//based on https://github.com/atotto/clipboard/blob/master/clipboard_windows.go (3-clause BSDL)
int zpbpaste(const int argc, const char **argv){
#ifdef STANDALONE
	initstdio();
#endif
	if(!OpenClipboard(NULL))return 1;
	HANDLE h=GetClipboardData(CF_TEXT);
	if(!h){CloseClipboard();return 1;}
	char *p=GlobalLock(h);
	fwrite(p,1,strlen(p),stdout);
	GlobalUnlock(h);
	CloseClipboard();
	return 0;
}
int zpbcopy(const int argc, const char **argv){
#ifdef STANDALONE
	initstdio();
#endif
///
	u8 *pups=NULL;
	unsigned int sizups;

	if(~ftell(stdin)){
		sizups=filelength(fileno(stdin));
		pups=(u8*)malloc(sizups);
		if(!pups){
			fprintf(stderr,"cannot allocate memory\n");return 4;
		}
		fread(pups,1,sizups,stdin);
	}else{ //if not file
		sizups=0;
		pups=NULL;
		for(;;){
			unsigned int readlen=fread(buf,1,BUFLEN,stdin);
			if(!readlen)break;
			u8 *tmp=(u8*)malloc(sizups+readlen);
			if(!tmp){if(pups)free(pups);fprintf(stderr,"cannot allocate memory\n");return 4;}
			memcpy(tmp,pups,sizups);
			memcpy(tmp+sizups,buf,readlen);
			if(pups)free(pups);
			pups=tmp,tmp=NULL;
			sizups+=readlen;
			if(readlen<BUFLEN)break;
		}
	}
///

	if(!OpenClipboard(NULL)){free(pups);return 1;}
	if(!EmptyClipboard()){free(pups);CloseClipboard();return 1;}
	HANDLE h=GlobalAlloc(0,sizups+1);
	char *p=GlobalLock(h);
	strcpy(p,pups);
	GlobalUnlock(h);
	SetClipboardData(CF_TEXT,h);
	CloseClipboard();
	free(pups);
	return 0;
}

#else

static void myexecvp(char **args){
	execvp(args[0],args);
}

int zpbpaste(const int argc, const char **argv){
#if defined(__APPLE__)
	myexecvp((char*[]){"pbpaste",NULL});
#else
	myexecvp((char*[]){"xsel","--clipboard","--output",NULL});
	myexecvp((char*[]){"xclip","-out","-selection","clipboard",NULL});
#endif
	fprintf(stderr,"failed to launch pbpaste\n");
	return 1;
}
int zpbcopy(const int argc, const char **argv){
#if defined(__APPLE__)
	myexecvp((char*[]){"pbcopy",NULL});
#else
	myexecvp((char*[]){"xsel","--clipboard","--input",NULL});
	myexecvp((char*[]){"xclip","-in","-selection","clipboard",NULL});
#endif
	fprintf(stderr,"failed to launch pbcopy\n");
	return 1;
}

#endif
