nano ~/.bashrc
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h:\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]$ "

git fetch
git switch -c dev
git switch <branch-name>
git switch dev
git switch qa
git switch uat
git switch prod
git push  origin --all
git checkout -b <branch-name>

# ssh key ile github'a bağlanmak için
git remote set-url origin git@github.com:denizlimd/eShopOnWeb.git
ssh -T git@github.com







