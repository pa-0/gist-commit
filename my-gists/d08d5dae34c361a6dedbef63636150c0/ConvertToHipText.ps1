function ConvertTo-HipText {
    param($text)

    switch ($text) {
        “Ok, thanks!”                    { "kthx" }        
        “Talk to you later.”             { "ttyl" }
        “Ok, thanks! Talk to you later.” { "kthx ttyl" }
    }
}

ConvertTo-HipText “Ok, thanks! Talk to you later.”
ConvertTo-HipText “Ok, thanks!"
ConvertTo-HipText “Talk to you later.”