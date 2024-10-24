function Invoke-Thesaurus {
    param(
        $Word='Thesaurus',
        $FilterCategory
    )

    $language='en_US'
    $key='<get key here http://thesaurus.altervista.org/mykey>'
    $result="json"

    $endpoint = "http://thesaurus.altervista.org/thesaurus/v1?word=$word&language=$language&key=$key&output=$result"

    $(
        ForEach($item in (Invoke-RestMethod $endpoint).response.list) {                    
            ForEach($synonym in $item.synonyms.split('|')) {
                [pscustomobject]@{
                    Word = $Word
                    Synonym = $synonym -replace "\(similar term\)",""
                    Category = $item.Category -replace "\(|\)",""
                }
            }        
        }
    ) | where {$_.Category -match $FilterCategory}
}

function DoCombination {
    param($word1, $word2)
    
    $l1=Invoke-Thesaurus $word1
    $l2=Invoke-Thesaurus $word2

    foreach($item1 in $l1) {
        foreach($item2 in $l2) {
            "{0} {1}" -f $item1.Synonym,$item2.Synonym
        }
    }
}

DoCombination value proposition