# Clone all branches individually

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

my($remote_repo_url) = "git\@gitea.local:hypersolve/eskew.git";

for $branch (@branches)
{
    system("git clone --branch $branch $remote_repo_url $branch");
}