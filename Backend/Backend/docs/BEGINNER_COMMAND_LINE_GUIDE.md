# Command Line Guide for Beginners 🚀

## 🤔 What is the Command Line?

The **command line** (also called Terminal, Command Prompt, or CLI) is a text-based way to interact with your computer. Instead of clicking buttons, you type commands.

**Think of it like:**
- **GUI (Graphical User Interface)**: Clicking buttons and icons
- **CLI (Command Line Interface)**: Typing commands

Both do the same thing, but the command line is faster for developers!

---

## 🖥️ How to Open Command Line

### On Mac (macOS):
1. Press `Command + Space` (opens Spotlight search)
2. Type: `Terminal`
3. Press `Enter`
4. A black/white window opens - that's your terminal!

**Or:**
- Go to Applications → Utilities → Terminal

### On Windows:
1. Press `Windows Key + R`
2. Type: `cmd`
3. Press `Enter`
4. A black window opens - that's your command prompt!

**Or:**
- Press `Windows Key`
- Type: `Command Prompt`
- Click on it

### On Linux:
1. Press `Ctrl + Alt + T`
2. Terminal opens!

---

## 📝 Basic Commands You Need to Know

### 1. See Where You Are: `pwd`

**What it does:** Shows your current folder location

**Type:**
```bash
pwd
```

**Example output:**
```
/Users/apple/Glass
```

**Meaning:** You're in the `/Users/apple/Glass` folder

---

### 2. List Files: `ls` (Mac/Linux) or `dir` (Windows)

**What it does:** Shows all files and folders in your current location

**On Mac/Linux:**
```bash
ls
```

**On Windows:**
```bash
dir
```

**Example output:**
```
Backend
glassmobileapp
README.md
```

**Meaning:** These are the folders/files in your current location

---

### 3. Change Directory (Go to a Folder): `cd`

**What it does:** Moves you into a different folder

**Type:**
```bash
cd Backend
```

**Meaning:** Go into the "Backend" folder

**Go back up one folder:**
```bash
cd ..
```

**Go to your home folder:**
```bash
cd ~
```

**Go to a specific folder:**
```bash
cd /Users/apple/Glass/Backend
```

---

### 4. Create a File: `touch` (Mac/Linux) or `echo` (Windows)

**On Mac/Linux:**
```bash
touch myfile.txt
```

**On Windows:**
```bash
echo. > myfile.txt
```

---

### 5. Run a Command: Just Type It!

**Example:**
```bash
python --version
```

**Meaning:** Check if Python is installed and what version

---

## 🎯 Commands You'll Use for Deployment

Here are the specific commands you'll need:

### 1. Check if gcloud is Installed
```bash
gcloud --version
```

**What to expect:**
- If installed: Shows version number ✅
- If not installed: Says "command not found" ❌

---

### 2. Navigate to Your Backend Folder
```bash
cd /Users/apple/Glass/Backend
```

**Or if you're already in Glass folder:**
```bash
cd Backend
```

---

### 3. Initialize Google Cloud
```bash
gcloud init
```

**What happens:**
- Opens a browser window
- You sign in
- You select your project
- Done!

---

### 4. Deploy Your App (Later)
```bash
gcloud app deploy
```

**What happens:**
- Uploads your code
- Deploys to Google Cloud
- Shows you the URL when done

---

## 💡 Tips for Beginners

### Tip 1: Copy and Paste
- You can **copy** commands from guides
- **Paste** them into terminal
- On Mac: `Command + V`
- On Windows: Right-click → Paste

### Tip 2: Use Tab for Auto-complete
- Type part of a folder name
- Press `Tab`
- It completes the name automatically!

**Example:**
```bash
cd Bac[Press Tab]
```
Becomes:
```bash
cd Backend
```

### Tip 3: Use Arrow Keys
- **Up Arrow**: Shows previous commands
- **Down Arrow**: Shows next commands
- Saves you from typing again!

### Tip 4: Clear the Screen
```bash
clear
```
**On Windows:**
```bash
cls
```

### Tip 5: If Something Goes Wrong
- Press `Ctrl + C` to stop/cancel a command
- This is your "escape" button!

---

## 🚨 Common Mistakes (And How to Fix Them)

### Mistake 1: "Command not found"
**Problem:** The command doesn't exist or isn't installed

**Solution:** 
- Check spelling
- Make sure the tool is installed
- Check if you're in the right folder

---

### Mistake 2: "No such file or directory"
**Problem:** The folder/file doesn't exist

**Solution:**
- Use `ls` or `dir` to see what's actually there
- Check spelling
- Make sure you're in the right location

---

### Mistake 3: "Permission denied"
**Problem:** You don't have permission to do that

**Solution:**
- On Mac/Linux: Try `sudo` before the command (asks for password)
- On Windows: Run Command Prompt as Administrator

---

## 📚 Practice Exercise

Let's practice! Open your terminal and try these:

### Exercise 1: See Where You Are
```bash
pwd
```
**Expected:** Shows your current folder path

---

### Exercise 2: List Files
**On Mac/Linux:**
```bash
ls
```

**On Windows:**
```bash
dir
```
**Expected:** Shows files and folders

---

### Exercise 3: Go to Your Backend Folder
```bash
cd /Users/apple/Glass/Backend
```

Then check where you are:
```bash
pwd
```
**Expected:** `/Users/apple/Glass/Backend`

---

### Exercise 4: List Files in Backend
```bash
ls
```
**Expected:** Shows files like `main.py`, `app/`, etc.

---

## 🎓 What You Need to Know for Deployment

**Good news!** You only need to know these 5 things:

1. ✅ How to open Terminal/Command Prompt
2. ✅ How to type commands (just copy and paste!)
3. ✅ How to navigate folders (`cd`)
4. ✅ How to see files (`ls` or `dir`)
5. ✅ How to cancel commands (`Ctrl + C`)

**That's it!** Everything else, you can copy from the guides.

---

## 🆘 Getting Help

### If You're Stuck:

1. **Check the error message** - It usually tells you what's wrong
2. **Copy the error** - You can paste it and ask for help
3. **Try `Ctrl + C`** - Cancel and try again
4. **Check spelling** - Commands are case-sensitive!

### Useful Help Commands:

**Get help on any command:**
```bash
gcloud --help
```

**Get help on a specific command:**
```bash
gcloud init --help
```

---

## 🎯 Next Steps

Now that you understand the basics:

1. **Open your Terminal/Command Prompt**
2. **Try the practice exercises above**
3. **When comfortable, proceed with deployment**

**Remember:** 
- You can always copy and paste commands
- If something doesn't work, just ask!
- Take it one step at a time

---

## 📖 Quick Reference Card

| What You Want | Command (Mac/Linux) | Command (Windows) |
|---------------|---------------------|-------------------|
| See current folder | `pwd` | `cd` |
| List files | `ls` | `dir` |
| Go to folder | `cd folder_name` | `cd folder_name` |
| Go back | `cd ..` | `cd ..` |
| Clear screen | `clear` | `cls` |
| Cancel command | `Ctrl + C` | `Ctrl + C` |
| Auto-complete | `Tab` | `Tab` |
| Previous command | `Up Arrow` | `Up Arrow` |

---

**You're ready!** 🎉 

Now you can follow the deployment guides. Just copy and paste the commands, and you'll be fine!

