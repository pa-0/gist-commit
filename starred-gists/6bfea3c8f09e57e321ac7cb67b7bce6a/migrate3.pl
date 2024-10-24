# Replace old submodules URLs in .gitmodules files

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
    system("cd $branch && sed -i \"s|git\@gitea.local:hypersolve/eskew.git|git\@github.com:DynamicDistreteChoiceForEcon/eskew.git|g\" .gitmodules && git add .gitmodules && git commit -m \"Updating .gitmodules to use new URLs for components\" && git push origin $branch");
}