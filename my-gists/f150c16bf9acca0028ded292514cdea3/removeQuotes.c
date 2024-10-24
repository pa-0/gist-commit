void removeQuotes(LPSTR szCommand)
{
    int nGet = 0, nSet = 0;

    while (szCommand[nGet] != '\0')
    {
        if  (szCommand[nGet] == '\"') 
            nGet++;
        else
        {
            szCommand[nSet] = szCommand[nGet];
            nSet++;
            nGet++;
        }
    }

    szCommand[nSet] = '\0';
}