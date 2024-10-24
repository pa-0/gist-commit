# Recursively update submodules, until all of their dependencies are up to date.
# apt install libconfig-tiny-perl

use strict;
use warnings;
 
use Config::Tiny;

my(@components) = (
    "eskew",
    "combinations",
    "distributed",
    "earnest",
    "emax",
    "engine-hpc",
    "engine-trivial",
    "levon",
    "sobolrng",
    "storage",
    "xorwow"
);

my($remote_repo_url) = "git\@github.com:DynamicDistreteChoiceForEcon/eskew.git";

while (1)
{
    my($updated) = 0;

    foreach my $component (@components)
    {
        my($filename) = "$component/.gitmodules";
        my($gitmodules) = Config::Tiny->read($filename, 'utf8');

        system("cd $component && git submodule init && git submodule update");

        foreach my $module (keys %{$gitmodules})
        {
            print "[$module]\n";

            my($path) = $gitmodules->{$module}->{"path"};
            my($url) = $gitmodules->{$module}->{"url"};
            my($branch) = $gitmodules->{$module}->{"branch"};
            my($name) = $path;
            $name =~ s/^.*\///g;

            if (not ($url eq "git\@github.com:DynamicDistreteChoiceForEcon/eskew.git"))
            {
                next;
            }

            my($cmd) = "cd $component && cd $path && git checkout $branch && git pull origin $branch";
            print "$cmd\n";
            system($cmd);
            my($dirty) = join("", `cd $component && git status --porcelain`);
            chomp $dirty;
            if ($dirty ne "")
            {
                system("cd $component && git add $path && git commit -m \"Updating submodule $name\"");
                $updated = 1;
            }
            my($push) = join("", `cd $component && git push origin $component 2>&1`);
            chomp $push;
            if ($push ne "Everything up-to-date")
            {
                $updated = 1;
            }
        }
    }

    if (!$updated)
    {
        last;
    }
}