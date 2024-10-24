for repo in $(gh repo list -L 100 | awk {'print $1}'); do
  for pr_no in $(gh pr list -R $repo | awk {'print $1}'); do
    gh pr merge -R $repo -s $pr_no
  done
done
