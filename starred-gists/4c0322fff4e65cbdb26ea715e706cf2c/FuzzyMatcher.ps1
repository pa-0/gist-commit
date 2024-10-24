<#
    yoinked and just stripped the namespace and change internal to public
    https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/utils/FuzzyMatch.cs
    https://www.geeksforgeeks.org/damerau-levenshtein-distance/
    https://yassineelkhal.medium.com/the-complete-guide-to-string-similarity-algorithms-1290ad07c6b7
#>
Add-Type -TypeDefinition @'
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Globalization;
public class FuzzyMatcher
{
    internal readonly uint MinimumDistance;

    public FuzzyMatcher(uint minimumDistance)
    {
        MinimumDistance = minimumDistance;
    }

    /// <summary>
    /// Determine if the two strings are considered similar.
    /// </summary>
    public bool IsFuzzyMatch(string candidate, string pattern)
    {
        return IsFuzzyMatch(candidate, pattern, out _);
    }

    /// <summary>
    /// Determine if the two strings are considered similar, and return the similarity score.
    /// </summary>
    /// <param name="candidate">The candidate string to be compared.</param>
    /// <param name="pattern">The pattern string to be compared with.</param>
    /// <returns>True if the two strings have a distance <= MinimumDistance.</returns>
    public bool IsFuzzyMatch(string candidate, string pattern, out int score)
    {
        score = GetDamerauLevenshteinDistance(candidate, pattern);
        return score <= MinimumDistance;
    }

    /// <summary>
    /// Compute the case-insensitive distance between two strings.
    /// Based off https://www.csharpstar.com/csharp-string-distance-algorithm/.
    /// </summary>
    /// <param name="string1">The first string to compare.</param>
    /// <param name="string2">The second string to compare.</param>
    /// <returns>The distance value where the lower the value the shorter the distance between the two strings representing a closer match.</returns>
    public static int GetDamerauLevenshteinDistance(string string1, string string2)
    {
        string1 = string1.ToUpper(CultureInfo.CurrentCulture);
        string2 = string2.ToUpper(CultureInfo.CurrentCulture);

        var bounds = new { Height = string1.Length + 1, Width = string2.Length + 1 };

        int[,] matrix = new int[bounds.Height, bounds.Width];

        for (int height = 0; height < bounds.Height; height++)
        {
            matrix[height, 0] = height;
        }

        for (int width = 0; width < bounds.Width; width++)
        {
            matrix[0, width] = width;
        }

        for (int height = 1; height < bounds.Height; height++)
        {
            for (int width = 1; width < bounds.Width; width++)
            {
                int cost = (string1[height - 1] == string2[width - 1]) ? 0 : 1;
                int insertion = matrix[height, width - 1] + 1;
                int deletion = matrix[height - 1, width] + 1;
                int substitution = matrix[height - 1, width - 1] + cost;

                int distance = Math.Min(insertion, Math.Min(deletion, substitution));

                if (height > 1 && width > 1 && string1[height - 1] == string2[width - 2] && string1[height - 2] == string2[width - 1])
                {
                    distance = Math.Min(distance, matrix[height - 2, width - 2] + cost);
                }

                matrix[height, width] = distance;
            }
        }
        return matrix[bounds.Height - 1, bounds.Width - 1];
    }
}
'@

$strings = [ordered]@{
    Test1 = @{
        String1  = 'MyFirstString'
        String2  = 'MyFirstStringNew'
        Distance = 5
    }
    Test2 = @{
        String1  = "Hello, World!"
        String2  = "Hello, Wrold!"
        Distance = 2
    }
    Test3 = @{
        String1  = "PowerShell"
        String2  = "PowersHell"
        Distance = 1
    }
    Test4 = @{
        String1  = "FuzzyMatcher"
        String2  = "FuzzyMatch"
        Distance = 2
    }
    Test5 = @{
        String1  = "ArtificialIntelligence"
        String2  = "ArtificalInteligence"
        Distance = 2
    }
    Test6 = @{
        String1  = "MachineLearning"
        String2  = "MachinLearnin"
        Distance = 2
    }
    Test7 = @{
        String1  = "Change FuzzyMatcher to a public class"
        String2  = "Because now its internal"
        Distance = 1
    }
    Test8 = @{
        String1  = "Lorem Ipsum is simply dummy text of the printing and typesetting industry"
        String2  = "Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old."
        Distance = 89
    }
}
foreach ($test in $strings.GetEnumerator()) {
    $out = $null
    $fuzzy = [FuzzyMatcher]::new($test.Value.Distance)
    $isMatch = $fuzzy.IsFuzzyMatch($test.Value.String1, $test.Value.String2, [ref]$out)
    [PSCustomObject]@{
        Test            = $test.Name
        String1         = $test.Value.String1
        String2         = $test.Value.String2
        AllowedDistance = $test.Value.Distance
        Distance        = $out
        IsMatch         = $isMatch
    }
}
# can call the method directly as well, outputs the distance
# [FuzzyMatcher]::GetDamerauLevenshteinDistance('woo','waa')
# [FuzzyMatcher]::GetDamerauLevenshteinDistance('MyFirstString','MyFirstStringNew')
