$code = @"
Paper 100
Pen 0
Line 50 77 22 27
Line 22 27 78 27
Line 78 27 50 77
"@

$svg = @()

try {
    $pgm = $code.Split("`n")
    $tokens = $pgm -split "[\t\f\v ]+"
    $tokenCount = $tokens.Count

    $svg = @()

    for ($idx = 0; $idx -lt $tokenCount - 1; $idx++) {
        $token = $tokens[$idx]

        switch ($token) {
            "Paper" {
                [int]$paperColor = $tokens[++$idx]
                $svg += '<svg width="100" height="100" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg" version="1.1">'
            }

            "Pen" {
                [int]$color = $tokens[++$idx]
                $rgb = "rgb({0}%, {0}%, {0}%)" -f $color
                $svg += "`t" + "<rect x='0' y='0' width='100' height='100' fill='$rgb'></rect>"
            }

            "Line" {
                $x1 = $tokens[++$idx]
                $y1 = $tokens[++$idx]
                $x2 = $tokens[++$idx]
                $y2 = $tokens[++$idx]

                $rgb = "rgb({0}%, {0}%, {0}%)" -f $paperColor
                $svg += "`t" + "<line x1='$x1' y1='$y1' x2='$x2' y2='$y2' stroke='$rgb' stroke-linecap='round'></line>"
            }
        }
    }

    $svg += '</svg>'

    $html = $svg -join "`r`n"
} catch {
    $html = $Error[0].exception.innerException.ToString()
}

$html