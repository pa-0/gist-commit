# Singleton

class Product {
    $Name

    Product($name) {
        $this.Name = $name
    }
}

class Creator {
    static [Product]$product

    static [Product] GetProduct() {
        if ($null -eq [Creator]::product) {
            [Creator]::product = [Product]::new((Get-Date))
        }
  
        return [Creator]::product
    }
}

$p = [Creator]::GetProduct()
$p