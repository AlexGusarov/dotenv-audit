# 🌱 dotenv-audit

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

---

## 📦 Installation

Download the script:

```bash
curl -O https://raw.githubusercontent.com/AlexGusarov/dotenv-audit/main/dotenv-audit.sh
chmod +x dotenv-audit.sh
```

Or clone the repository: 

```bash
git clone https://github.com/your-username/dotenv-audit.git
cd dotenv-audit
chmod +x dotenv-audit.sh
```

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
| DATABASE_URL                                             |
+-------------------------------------------------------+

❌ Audit failed. Found issues in env files.
```

When everything is correct:

```bash
✅ Audit passed. All variables matched.
```

## 🛠️ Command Line Flags

| Flag              | Description                                                |
|-------------------|------------------------------------------------------------|
| `--fix`           | ➕ Add missing variables to `.env` with empty values        |
| `--json`          | 📦 Output result as JSON (for CI, automation, tools)       |
| `--strict`        | 🧪 *Reserved for future strict mode*                        |
| `-h`, `--help`    | 🆘 Show help with usage                                     |
| `-v`, `--version` | 🧾 Print version and author  

🛡 When using --fix, a backup is automatically created as .env.bak.
No lines are overwritten. All additions are appended to the end of .env.                               |

## 🧪 CI Integration (GitHub Actions)

```yaml
- name: Audit .env
  run: |
    ./dotenv-audit.sh .env .env.example --json
```

## 👨‍💻 Author

**Alex Gusarov**  
Shell scripting enthusiast and web developer  

## 📄 License

MIT License — free for personal & commercial use.
