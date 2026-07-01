---
name: commit-progress
description: 提交当前进度到 git 并推送到 GitHub。当完成一个功能点开发、bug 修复或文档更新后，用户想提交/推送代码，或说“提交代码”“commit”“推上去”时使用。固化本项目的中文提交风格、直推 main 约定与本地设置忽略规则。
---

# commit-progress —— 提交并推送本项目进度

「日记」项目的提交工作流。用户约定：**每完成一个功能点开发、bug 修复或文档更新，就提交一次并推送到 GitHub**（已授权的持续流程，不必每次再问是否提交）。本 skill 把提交的所有约定固化下来，保证每次提交一致、干净。

## 何时触发

- 完成一个可独立描述的功能点 / bug 修复 / 文档更新之后。
- 用户说「提交代码」「commit」「推上去」「保存进度」等。
- 一次提交应对应**一个连贯的改动单元**；不要把无关的多件事塞进一个 commit。

## 提交前检查

1. `git status` + `git diff --stat` 看清改动范围，确认这些改动属于同一个逻辑单元。
2. 若有跑测试/analyze 的条件，先确保 `flutter analyze` 通过再提交（不提交明显坏掉的代码）。
3. **绝不提交** `.claude/settings.local.json`（本地个人权限设置）。它已在 `.gitignore` 中；若发现未被忽略，先补进 `.gitignore` 再提交。
4. 不提交疑似密钥文件（`.env`、凭据等）。
5. 按文件名精确 `git add`，不要用 `git add -A` / `git add .`（避免误纳入未预期文件）。

## 提交信息规范

- **中文**，沿用项目历史风格（看 `git log --oneline -8` 对齐语气）。
- 首行是简短主题：`<动作>：<对象与要点>`。动作用「新增/修复/更新/重构/优化」等，准确反映改动性质。
- 需要时空一行后加要点列表（`- ...`）说明「为什么」而非逐行复述「改了什么」。
- 结尾附：`Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- 用 HEREDOC 传多行信息，保证格式：

```bash
git commit -m "$(cat <<'EOF'
修复：折线图重绘不及时的 bug

- xxx
- xxx

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

## 推送约定

- **单人项目，直推 `main`**，不走 PR 流程（用户明确要简单提交）。
- 推送前先 `git remote -v` 验证 remote 仍是 `https://github.com/yangjiao111-cpu/diary.git`（不盲信记忆，地址可能变）。
- `git push origin main`。
- **gh CLI 不在 git bash 的 PATH 里**；若需要 gh，前缀 `export PATH="$PATH:/c/Program Files/GitHub CLI"` 或用完整路径 `"/c/Program Files/GitHub CLI/gh.exe"`。日常 push 用 `git` 即可，无需 gh。

## 完成后

- `git log --oneline -1` 确认提交落地。
- 向用户简短汇报：提交了什么 + 已推送到哪个分支。

## 相关记忆

- `github-repo-and-workflow`：仓库地址与工作流约定的来源。
- `flutter-windows-build-gotchas`：提交前若要跑 analyze/test 的环境前缀。
