# What's this

Various ways to run code in parallel are showcased here. I've made this demo while looking for a proper way to run file minification for my blog.

More info at http://mxii.eu.org/2016/09/16/parallel-processing-in-powershell/

# How to make it run

1. Put these binaries somewhere in execution path:

    * https://github.com/tdewolff/minify/tree/master/cmd/minify
    * http://jpegclub.org/jpegtran/
    * http://optipng.sourceforge.net/

2. Install this module:

    https://github.com/proxb/PoshRSJob

3. This code is already included here for convenience:

    https://github.com/RamblingCookieMonster/Invoke-Parallel

    (If you have some license complaints about this demo then I'll remove it.)

4. Make a folder '.\public', put jpegs, pngs, htmls and so on in there.

5. Run whatever part you need as is or with psake.
