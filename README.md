# Gitflow automation
gitflow의 여러 정책들을 자동화 해 주는 github action 입니다.

## 기능들
1. 특정 prefix가 붙은 브랜치가 base 브랜치에 머지되면 자동으로 target 브랜치에도 머지합니다.

## 사용방법
```yaml
name: gitflow-automation
on:
  pull_request:
    types: [closed]
jobs:
  create-auto-pr:
    name: Gitflow Automation
    runs-on: ubuntu-latest
    env:
    steps:
      - name: gitflow-automation
        uses: peoplefund-tech/gitflow-automation@v0.1.1
        env:
          BRANCH_PREFIX: "hotfix/"
          TARGET_BRANCH: "develop"
          BASE_BRANCH: "master"
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          BOT_TOKEN: ${{ secrets.BOT_TOKEN }} # 선택사항

```
- `BRANCH_PREFIX`: hotfix 브랜치의 prefix를 적어 주세요.
- `TARGET_BRANCH`: automerge되어야 하는 브랜치를 적어주세요.
- `BASE_BRANCH`: event가 발생할 브랜치를 적어주세요.
- `GITHUB_TOKEN`: 특별한 경우가 아닌 이상 예제와 동일하게 적어주시면 됩니다. 
- `BOT_TOKEN`: PR이 1명 이상의 assigner가 필요한 경우 assign할 bot의 token을 등록해 주세요. github repository의 secrets를 이용하는 것을 권장합니다.
