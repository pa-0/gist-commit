void StrTrimLeft(char *source, char *dest)
{
    int nIndex = 0;

    while (source[nIndex] == ' ')
        nIndex++;
	
    strcpy(dest, &source[nIndex]);
}