# list open milestones (JSON)
gh api \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/kiwiproject/kiwi-bom/milestones
  
# list open milestones (extract title)
gh api \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/kiwiproject/kiwi-bom/milestones \
  | jq -r .[].title
  
# list open milestones (extract id, number, and title as TSV)
gh api \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/kiwiproject/kiwi-bom/milestones \
  | jq -r '.[] | [.id, .number, .title] | @tsv'
  
# paginate closed milestones (extract id, number, and title as TSV)
gh api \
  -H "Accept: application/vnd.github.v3+json" \
  "/repos/kiwiproject/kiwi-bom/milestones?state=closed&page=1" \
  | jq -r '.[] | [.id, .number, .title] | @tsv'
  
# paginate closed milestones
# page 1:
gh api -H "Accept: application/vnd.github.v3+json" "repos/kiwiproject/kiwi-bom/milestones?state=closed&page=1" | jq -r '.[].title'

# page 2:
gh api -H "Accept: application/vnd.github.v3+json" "repos/kiwiproject/kiwi-bom/milestones?state=closed&page=2" | jq -r '.[].title'


# list PRs in current repo
gh pr list

# list PRs in specific repo
gh pr list --repo kiwiproject/kiwi-bom

# add milestone in current repo
for i in $(seq 920 929); do echo $i: ; gh pr edit --milestone 2.0.9 $i ; done

# add milestone in specific repo
for i in $(seq 920 929); do echo $i: ; gh pr edit --repo kiwiproject/kiwi-bom --milestone 2.0.9 $i ; done

# approve in current repo
for i in $(seq 920 929); do echo $i: ; gh pr review --approve $i ; done

# approve in specific repo
for i in $(seq 920 929); do echo $i: ; gh pr review --repo kiwiproject/kiwi-bom --approve $i ; done

# merge in current repo
for i in $(seq 920 929); do echo $i: ; gh pr merge --squash --delete-branch --auto $i ; done

# merge in specific repo
for i in $(seq 920 929); do echo $i: ; gh pr merge --repo kiwiproject/kiwi-bom --squash --delete-branch --auto $i ; done
