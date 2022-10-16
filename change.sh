# ## Make sure your local repo settings are correct
# git config --local --list
# git config --local user.name "anonym" 
# git config --local user.email "0xanonym@proton.me"

# ## Change previous n commits
# git rebase -i HEAD~n
# # choose the commits to change by adding 'pick' or 'reword' (only for changing the message)
# git commit --amend --author="r4v3r23 <email@address.com>"
# # change first commit in repo
# git rebase -i --root
# # change date of commit to now (maintaining author)
# git commit --amend --date="$(date -R)"
# # change date and author of commit
# git commit --amend --reset-author 

## Change all commits with --commit-filter. If your local config was wrong
git filter-branch --commit-filter 'if [ "$GIT_AUTHOR_NAME" = "r4v3r23" ];
  then export GIT_AUTHOR_NAME="anonym"; export GIT_AUTHOR_EMAIL=0xanonym@proton.me;
  export GIT_COMMITTER_NAME="anonym"; export GIT_COMMITTER_EMAIL=0xanonym@proton.me
  fi; git commit-tree "$@"'
