$data = @"
IH - Order 1
ID - Product 1 for order 1
IH - Order 2
ID - Product 1 for Order 2
ID - Product 2 for Order 2
"@ -split "`n"

$result=[ordered]@{}

foreach ($record in $data) {
    if($record[1] -eq 'H') {
        $orderID=$record.split('-')[1].Trim()
        $result.$orderID=@()
    } elseif($record[1] -eq 'D') {
        $detailInfo=$record.split('-')[1].Trim()        
        $result.$orderID+=$detailInfo
    }
}

$result