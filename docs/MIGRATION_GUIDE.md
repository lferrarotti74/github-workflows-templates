
---

## 2️⃣ `MIGRATION_GUIDE.md`

```markdown
# Migration Guide: Moving Local Workflows to Reusable Workflows

This guide helps you migrate existing per-repo GitHub workflows into the **centralized reusable workflow template**.

---

## 1️⃣ Preparation

1. Ensure you have access to the `github-workflows-templates` repository.  
2. Identify all repositories that will migrate to reusable workflows.  
3. Verify each repo has a valid `Dockerfile` and existing workflow files.  
4. Backup existing `.github/workflows/*.yml` files.

---

## 2️⃣ Backup Existing Workflows

- Create a backup folder in your repo:  
```bash
mkdir backup-workflows
cp .github/workflows/*.yml backup-workflows/

