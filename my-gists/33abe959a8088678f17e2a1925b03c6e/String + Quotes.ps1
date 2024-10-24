# In PowerShell, there are three types of quotes that can be used to define strings:

# Double-quoted strings: Double-quoted strings (") allow for variable expansion and escape sequences.
"Hello, $name!"

# Single-quoted strings: Single-quoted strings (') treat the content literally, without variable expansion or escape sequences.
'Hello, $name!'

# Here-strings: Here-strings (@" "@ or @' '@) allow multiline string literals and preserve line breaks and formatting.
$message = @"
This is a multiline
string using a here-string.
It preserves line breaks and formatting.
"@

# These quotes can be used interchangeably depending on your requirements. Double-quoted strings are commonly used when you need to include variable values within the string. Single-quoted strings are useful when you want to treat the content literally without variable expansion. Here-strings are beneficial for multiline strings that require preserving line breaks and formatting.
