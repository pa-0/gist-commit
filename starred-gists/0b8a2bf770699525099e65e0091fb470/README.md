# Bash string manipulation cheatsheet

<table>
	<tr>
		<th align="left" colspan="2">Assignment</th>
	</tr>
	<tr>
		<td>Assign <code>value</code> to <code>variable</code> if <code>variable</code> is not already set, <code>value</code> is returned.<br /><br />Combine with a <code>:</code> no-op to discard/ignore return <code>value</code>.</td>
		<td><code>${variable="value"}</code><br /><code>: ${variable="value"}</code></td>
	</tr>
	<tr>
		<th align="left" colspan="2">Removal</th>
	</tr>
	<tr>
		<td>Delete shortest match of <code>needle</code> from front of <code>haystack</code>.</td>
		<td><code>${haystack#needle}</code></td>
	</tr>
	<tr>
		<td>Delete longest match of <code>needle</code> from front of <code>haystack</code>.</td>
		<td><code>${haystack##needle}</code></td>
	</tr>
	<tr>
		<td>Delete shortest match of <code>needle</code> from back of <code>haystack</code>.</td>
		<td><code>${haystack%needle}</code></td>
	</tr>
	<tr>
		<td>Delete longest match of <code>needle</code> from back of <code>haystack</code>.</td>
		<td><code>${haystack%%needle}</code></td>
	</tr>
	<tr>
		<th align="left" colspan="2">Replacement</th>
	</tr>
	<tr>
		<td>Replace first match of <code>needle</code> with <code>replacement</code> from <code>haystack</code>.</td>
		<td><code>${haystack/needle/replacement}</code></td>
	</tr>
	<tr>
		<td>Replace all matches of <code>needle</code> with <code>replacement</code> from <code>haystack</code>.</td>
		<td><code>${haystack//needle/replacement}</code></td>
	</tr>
	<tr>
		<td>If <code>needle</code> matches front of <code>haystack</code> replace with <code>replacement</code>.</td>
		<td><code>${haystack/#needle/replacement}</code></td>
	</tr>
	<tr>
		<td>If <code>needle</code> matches back of <code>haystack</code> replace with <code>replacement</code>.</td>
		<td><code>${haystack/%needle/replacement}</code></td>
	</tr>
	<tr>
		<th align="left" colspan="2">Substitution</th>
	</tr>
	<tr>
		<td>If <code>variable</code> not set, return <code>value</code>, else <code>variable</code>.</td>
		<td><code>${variable-value}</code></td>
	</tr>
	<tr>
		<td>If <code>variable</code> not set <em>or</em> empty, return <code>value</code>, else <code>variable</code>.</td>
		<td><code>${variable:-value}</code></td>
	</tr>
	<tr>
		<td>If <code>variable</code> set, return <code>value</code>, else null string.</td>
		<td><code>${variable+value}</code></td>
	</tr>
	<tr>
		<td>If <code>variable</code> set <em>and</em> not empty, return <code>value</code>, else null string.</td>
		<td><code>${variable:+value}</code></td>
	</tr>
	<tr>
		<th align="left" colspan="2">Extraction</th>
	</tr>
	<tr>
		<td>Extract <code>length</code> characters from <code>variable</code> starting at <code>position</code>.</td>
		<td><code>${variable:position:length}</code></td>
	</tr>
	<tr>
		<td>Return string length of <code>variable</code>.</td>
		<td><code>${#variable}</code></td>
	</tr>
	<tr>
		<th align="left" colspan="2">Escaping</th>
	</tr>
	<tr>
		<td>Single quotes inside a single quoted string.</td>
		<td><code>echo 'Don'\''t break my escape!'</code></td>
	</tr>
	<tr>
		<th align="left" colspan="2">Indirection</th>
	</tr>
	<tr>
		<td>Return value of variable name held in <code>indirect</code>, else <code>value</code>.</td>
		<td><code>indirect="apple"</code><br /><code>apple="fruit"</code><br /><code>${!indirect-value}</code></td>
	</tr>
</table>

## Reference

- https://tldp.org/LDP/abs/html/string-manipulation.html
- https://tldp.org/LDP/abs/html/parameter-substitution.html
- https://tldp.org/LDP/abs/html/ivr.html
- Special characters:
	- `*`: https://www.tldp.org/LDP/abs/html/special-chars.html#ASTERISKREF
	- `?`: https://www.tldp.org/LDP/abs/html/special-chars.html#WILDCARDQU
- https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
