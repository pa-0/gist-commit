#requires -module msterminalsettings,threadjob

###QUICKSTART
#FIRST: Run this in your Powershell Windows Terminal: Install-Module threadjob,msterminalsettings -scope currentuser
#THEN: iex (iwr git.io/invoketerminalgif)
#THEN: Get-Help Search-Giphy -Examples
#THEN: Get-Help Invoke-TerminalGif -Examples
#THEN: Search-Giphy | Format-List -prop *
#THEN: Invoke-TerminalGif https://media.giphy.com/media/g9582DNuQppxC/giphy.gif


function Search-Giphy {
    <#
.SYNOPSIS
    Fetches Gif Information and direct Gif Links from Giphy, a meme delivery service
.DESCRIPTION
    This is a frontend to the Giphy API to find and request gifs from Giphy. It implements the API described here: https://developers.giphy.com/docs/api/
.EXAMPLE
    PS> Search-Giphy
    Returns a random gif information object
    title          bitly_url              username source
    -----          ---------              -------- ------
    nick jonas GIF https://gph.is/1SR6uiv          https://ddlovatosrps.tumblr.com/post/120447116655/positive-nick-jonas-gif-hunt-under-the-cut-you
.EXAMPLE
    PS> Search-Giphy -ImageType Sticker
    Returns a random sticker information object
    title                                                             bitly_url              username source
    -----                                                             ---------              -------- ------
    festival woodstock Sticker by Wielka Orkiestra Świątecznej Pomocy https://gph.is/2mZ7V2k WOSP
.EXAMPLE
    PS> Search-Giphy -DirectURL
    Returns only the direct link to a random gif
    https://media3.giphy.com/media/q9WSYOP1KUlgc/giphy.gif?cid=f499c4a35d19a6596653673632f7ddec&rid=giphy.gif
.EXAMPLE
    PS> Search-Giphy -Filter "Excited"
    Returns GIFs that match 'Excited'
.EXAMPLE
    PS> Search-Giphy -Filter Excited -Channel reactions -tag cat -first 3
    Returns 3 GIFs that match 'Excited' in the reactions channel with tag of Cat
.EXAMPLE
    PS> Search-Giphy -Trending -First 3
    Get the top 3 trending gifs
.EXAMPLE
    PS> Search-Giphy -Translate -Phrase "cute flying bat" -Weirdness 5
    Translates the phrase "cute flying bat" to a Gif with a weirdness factor of 5 using Giphy's special sauce
.EXAMPLE
    PS> Search-Giphy -Translate -Phrase "cute flying bat" -Weirdness 5 -DirectUrl
    Translate the phrase "cute flying bat" to a gif with a Weirdness rating of 5.
.NOTES
    Created 2019 by Justin Grote
    The giphy public beta API key is embedded in this script and is subject to very frequent rate limiting. You can sign up for your own free Giphy API key, just be aware no special means in this script are used to "protect" the key.
    Recommendation so you don't have to specify it each time: $PSDefaultParameterValues['Search-Giphy:ApiKey'] = 'yourapikey'
#>
    [CmdletBinding(SupportsPaging, DefaultParameterSetName = 'random')]
    param (
        #If performing a search, this is a query string of a word or phrase to find. If using -Translate, this is the phrase you want to convert to a gif
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'search')]
        [String]$Filter,

        #If performing a search, limit to a verified channel. This is the same as specifying "@channelname" in the Filter parameter
        [Parameter(Position = 2, ParameterSetName = 'search')]
        [String]$Channel,

        #Specify a phrase and gfycat will translate that phrase into a gif
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'translate')]
        [String]$Phrase,

        #Specify a weirdness factor from 0 to 10. The translations will get weirder the higher number you specify
        [Parameter(ParameterSetName = 'translate')]
        [ValidateRange(0, 10)][int]$Weirdness,

        [Parameter(Position = 1, ParameterSetName = 'search')]
        [Parameter(Position = 1, ParameterSetName = 'random')]
        [String]$Tag,

        #Search Trending Gifs
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'trending')][Switch]$Trending,

        #Perform a gif translate, which will use the giphy "secret sauce" to make your phrase into a gif
        [Parameter(Position = 0, Mandatory, ParameterSetName = 'translate')][Switch]$Translate,

        #Fetch a random gif
        [Parameter(ParameterSetName = 'random')][Switch]$Random,

        #Specifying this switch will only return the original URI of a gif or gifs, which is easier to integrate into tools
        [Switch]$DirectURL,

        #Type of image (Gif or Sticker). Defaults to Gif.
        [ValidateSet('Gif', 'Sticker')]$ImageType = 'Gif',

        #Content rating of the gif. Specify G, PG, PG-13, or R. Searches PG gifs by default.
        [ValidateSet('G', 'PG', 'PG-13', 'R')][String]$Rating = 'PG',

        #API Key. Defaults to the Giphy Public Beta Key. It is recommended you register your own apikey at Giphy and use it
        [String]$APIKey = 'dc6zaTOxFJmzC'
    )

    function Join-Uri ([string]$uri, [string]$relativePath) {
        [uri]::new([uri]"$uri/", $relativePath)
    }

    $erroractionPreference = 'stop'
    $baseuri = "https://api.giphy.com/v1"
    $requestUri = Join-Uri -uri $baseuri -relativepath "${ImageType}s".toLower()
    $requestUri = Join-Uri $requestUri $PSCmdlet.ParameterSetName.toLower()

    $irmParams = @{
        UseBasicParsing = $true
        Method          = 'Get'
        URI             = $requestUri
        BODY            = [ordered]@{
            api_key = $APIKey
            rating  = $Rating
        }
    }

    $queryParams = $irmparams.body

    switch ($PSCmdlet.ParameterSetName) {
        'search' {
            $queryParams.q = $Filter
            if ($tag) { [string]$queryParams.q = "#$tag " + $queryParams.q }
            if ($channel) { [string]$queryParams.q = "@$channel " + $queryParams.q }
        }
        'translate' {
            $queryParams.s = $Phrase
            if ($Weirdness) { $queryParams.weirdness = $Weirdness }
        }
        'random' {
            if ($tag) { $queryParams.tag = $Tag }
        }
    }

    if ($PSCmdlet.PagingParameters.First -and $PSCmdlet.PagingParameters.First -ne 18446744073709551615) { $queryParams.limit = $PSCmdlet.PagingParameters.First }
    if ($PSCmdlet.PagingParameters.Skip) { $queryParams.body.offset = $PSCmdlet.PagingParameters.Skip }

    $GiphyResult = Invoke-RestMethod @irmParams -ErrorAction Stop
    $GiphyResultData = $GiphyResult.data

    if (-not $DirectUrl) {
        if (-not (Get-TypeData giphy.image)) { Update-TypeData -TypeName Giphy.Image -DefaultDisplayPropertySet title, bitly_url, username, source }
        $GiphyResultData | ForEach-Object {
            $PSItem.PSObject.TypeNames.Insert(0, 'Giphy.Image')
            $PSItem
        }
    } else {
        $GiphyResultData.images.original.url
    }
}

