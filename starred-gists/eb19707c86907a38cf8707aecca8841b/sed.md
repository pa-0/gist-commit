Some less than simple sed statements

# Remove every instance of pattern2 comming directly after pattern 1

```bash
stuff | sed -n '/pattern1.*/b remove
                b next
                :remove
                # Load a second long
                N
                # Remove the first line, I have already eliminated it
                s|.*\n||
                # Repeat if it matches pattern 2
                /^pattern2/b remove
                # Path for printing normal lines
                :next
                p'
```

Example:

```bash
echo "ok
1
foo2 222
3
4
foo1 111
foo2 234
foo2 3
foo2 4
foo2 5
5
foo2
6
foo2" | sed -n '/foo1.*/b remove
                b next
                :remove
                # Load a second long
                N
                # Remove the first line, I have already eliminated it
                s|.*\n||
                # Repeat if it matches pattern 2
                /^foo2/b remove
                # Path for printing normal lines
                :next
                p'
```

# Remove everything between two patterns (exclusive)

```bash
sed '/pattern1/,/pattern2/{//!d;}'
```

Example

```bash
echo "ok
1
foo2 222
3
4
foo1 111
foo2 234
foo2 3
foo2 4
foo2 5
5
foo1
6
foo2" | sed '/foo1/,/^[^f]/{//!d;}; /foo1/d'
```

The extra `/foo1/d` will remove foo1 too, so it can be partially inclusive if you want

The other patterns from https://stackoverflow.com/a/46434705/4166604 were all greedy on the second pattern

# Replace only the first instance of pattern in file

```bash
sed '1,/pattern/s/pattern/replace/'
#shortcut
sed '1,/pattern/s//replace/'
```

# Removing one instance of multiple lines

From: https://stackoverflow.com/a/46434705/4166604

- `sed -n -e '/b/,/d/!p' abcde` => ae
- `sed -n -e '/b/,/d/p' abcde` => bcd
- `sed -n -e '/b/,/d/{//!p}' abcde` => c
- `sed -n -e '/b/,/d/{//p}' abcde` => bd
- `sed -e '/b/,/d/!d' abcde` => bcd
- `sed -e '/b/,/d/d' abcde` => ae
- `sed -e '/b/,/d/{//!d}' abcde` => abde
- `sed -e '/b/,/d/{//d}' abcde` => ace
