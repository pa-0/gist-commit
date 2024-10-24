# Switch remote origin to a new one

my(@branches) = (
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

for $branch (@branches)
{
    system("cd $branch && git remote remove origin && git remote add origin $remote_repo_url && git push origin $branch");
}