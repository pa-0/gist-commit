ConvertFrom-JsonToClass @"
{
    "id" : 12345,
    "friend" : {
        "name" : "Mickey"
    },
    "pets" : {
        "Name" : "Spot",
        "Type" : "Dog",
        "age":14
    },
    "family" : {
        "name" : "John",
        "relationship" : "Brother"
    }
}
"@

##### Generates PowerShell v5 Classes

class RootObject {
	[int]$id
	[friend]$friend
	[pets]$pets
	[family]$family
}

class friend {
	[string]$name
}

class pets {
	[string]$Name
	[string]$Type
	[int]$age
}

class family {
	[string]$name
	[string]$relationship
}