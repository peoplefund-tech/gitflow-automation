# Gitflow hotfix automation
gitflow hotfix의 귀찮은 merge 정책을 자동화해 주는 github action 입니다.

## 사용방법
```
name: create-auto-pr
on:
  pull_request:
      types: [closed]
jobs:
  create-auto-pr:
    name: Create Auto PR
    runs-on: ubuntu-latest
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      steps:
        - name: cap-action
          uses: riemannulus/auto-create-pr@master
          env:
            BRANCH_PREFIX: "hotfix/"
            TARGET_BRANCH: "develop"
            BASE_BRANCH: "master"
```
- `BRANCH_PREFIX`: hotfix 브랜치의 prefix를 적어 주세요.
- `TARGET_BRANCH`: automerge되어야 하는 브랜치를 적어주세요.
- `BASE_BRANCH`: event가 발생할 브랜치를 적어주세요.
