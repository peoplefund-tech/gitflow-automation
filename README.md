# Gitflow automation
gitflow의 여러 정책들을 자동화 해 주는 github action 입니다.

## 기능들
1. 특정 prefix가 붙은 브랜치가 base 브랜치에 머지되면 자동으로 target 브랜치에도 머지합니다.

## 사용방법
```
name: gitflow-automation
on:
  pull_request:
    types: [closed]
jobs:
  create-auto-pr:
    name: Gitflow Automation
    runs-on: ubuntu-latest
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    steps:
      - name: gitflow-automation
        uses: peoplefund-tech/gitflow-automation@v0.1.0
        env:
          BRANCH_PREFIX: "hotfix/"
          TARGET_BRANCH: "develop"
          BASE_BRANCH: "master"
```
- `BRANCH_PREFIX`: hotfix 브랜치의 prefix를 적어 주세요.
- `TARGET_BRANCH`: automerge되어야 하는 브랜치를 적어주세요.
- `BASE_BRANCH`: event가 발생할 브랜치를 적어주세요.
