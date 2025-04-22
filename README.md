# 🌱 dotenv-audit

![Shell](https://img.shields.io/badge/Shell-Bash-blue.svg?logo=gnu-bash)
![Zero dependencies](https://img.shields.io/badge/Zero--dependencies-%E2%9C%94%EF%B8%8F-brightgreen)
![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey)

<details>
  <summary>🎥 <strong>Click to see dotenv-audit in action</strong></summary>

  <br/>

  <p align="center">
    <img src="./demo/demo.svg" alt="dotenv-audit demo" width="700"/>
  </p>
</details>

> ✅ Minimalistic `.env` audit tool — zero dependencies, max clarity.

**`dotenv-audit`** is a lightweight Bash script that compares `.env` and `.env.example` files.  
It helps you keep your environment variables in sync by reporting:

- ❌ Missing variables
- ⚠️ Extra variables
- 🔄 Variables with different values

---

## ✨ Features

- 🧪 Compares two `.env`-like files
- 🎯 Reports:
  - Missing variables
  - Extra variables
  - Variables with different values
- 🔧 `--fix` mode to auto-patch missing variables
- 📦 `--json` output for CI pipelines
- 🧘 Zero dependencies, pure Bash
- ✅ Safe for use in production
  
&nbsp;

## 🆚 Why not `dotenv-cli`, `dotenv-safe`, or `env-cmd`?

Unlike many npm-based tools, `dotenv-audit` is:

- 🧘 **Zero-dependency** — works in any Unix environment without installing anything
- 🐢 **Fast** — runs instantly, pure Bash
- 🔒 **Safe** — won't overwrite files, creates backups
- 🛠️ **Focused** — it's not a dotenv loader, it's a linter/auditor

Use it alongside any tool — or by itself — to keep your `.env` files in shape.

&nbsp;

## 🧩 Use Cases

- ✅ **Local dev sanity check** — quickly see what’s missing in your `.env`
- ✅ **CI/CD pipelines** — fail early when `.env` gets out of sync
- ✅ **Team onboarding** — ensure new devs don’t miss critical config
- ✅ **Template enforcement** — validate `.env.example` across projects
  
&nbsp;

## 📦 Installation

Download the script:

```bash
curl -O https://raw.githubusercontent.com/AlexGusarov/dotenv-audit/main/dotenv-audit.sh
chmod +x dotenv-audit.sh
```

Or clone the repository: 

```bash
git clone https://github.com/AlexGusarov/dotenv-audit.git
cd dotenv-audit
chmod +x dotenv-audit.sh
```
&nbsp;


## 🚀 Usage

Basic comparison:

```bash 
./dotenv-audit.sh .env .env.example
```

Auto-fix mode (patch missing variables):

```bash 
./dotenv-audit.sh .env .env.example --fix
```
JSON output for CI/CD:

```bash 
./dotenv-audit.sh .env .env.example --json
```
&nbsp;

## 📊 Example Output

When differences are found:

```bash
+---------------------------+---------------------------+
| Missing variables         | Extra variables           |
+---------------------------+---------------------------+
| API_KEY                   | DEBUG_MODE                |
+---------------------------+---------------------------+
| Variables with different values                       |
+-------------------------------------------------------+
| DATABASE_URL                                          |
+-------------------------------------------------------+

❌ Audit failed. Found issues in env files.
```

When everything is correct:

```bash
✅ Audit passed. All variables matched.
```
&nbsp;

## 🧪 Try It Yourself

Run a demo audit using the example files in `demo/`:

```bash
./dotenv-audit.sh demo/demo.env demo/demo.env.example
```
&nbsp;

## 🛠️ Command Line Flags

| Flag              | Description                                                |
|-------------------|------------------------------------------------------------|
| `--fix`           | ➕ Add missing variables to `.env` with empty values       |
| `--json`          | 📦 Output result as JSON (for CI, automation, tools)       |
| `--strict`        | 🧪 *Reserved for future strict mode*                       |
| `-h`, `--help`    | 🆘 Show help with usage                                    |
| `-v`, `--version` | 🧾 Print version and author                                |

🛡 When using --fix, a backup is automatically created as .env.bak.
No lines are overwritten. All additions are appended to the end of .env.

&nbsp;                              

## 🧪 CI Integration (GitHub Actions)

```yaml
- name: Audit .env
  run: |
    ./dotenv-audit.sh .env .env.example --json
```

&nbsp;

## 👨‍💻 Author

**Alex Gusarov**  
Shell scripting enthusiast and web developer. 
[github.com/AlexGusarov](https://github.com/AlexGusarov)

&nbsp;

## 📄 License

[MIT License](https://github.com/AlexGusarov/dotenv-audit/blob/main/LICENSE) — free for personal & commercial use.

---

⭐ Found it useful? Give it a star on [GitHub](https://github.com/AlexGusarov/dotenv-audit)!  
💬 Feedback and PRs are welcome!
