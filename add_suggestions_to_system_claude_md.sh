#!/bin/bash

# Script to create ~/.claude/CLAUDE.md if it doesn't exist and append content

CLAUDE_FILE="$HOME/.claude/CLAUDE.md"

# Content to append/create
CONTENT='## Follow-up Prompts
**🚨 ABSOLUTELY REQUIRED - NO EXCEPTIONS 🚨**

**IMPORTANT**: After answering any question or completing any task, always end your response with a section titled "**Next Steps:**" that includes 5 follow-up prompts. These should be:

- The most likely next questions or tasks based on the current context
- Copy-pasteable prompts that continue the agentic interaction naturally
- Focused on progressing the current work or exploring related areas, whatever you think is most useful to drive the ball forward.
- Formatted as a numbered list for easy selection

The goal is to make the workflow more efficient by providing ready-to-use prompts that anticipate the user'\''s next needs.

### Example Format:
```
**Next Steps:**
1. [Most likely immediate follow-up]
2. [Related task or question]
3. [Alternative approach or exploration]
4. [Debugging/testing related prompt]
5. [Documentation or cleanup task]
```

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they'\''re absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.'

# Check if content already exists in file
if [ -f "$CLAUDE_FILE" ] && grep -q "## Follow-up Prompts" "$CLAUDE_FILE" && grep -q "important-instruction-reminders" "$CLAUDE_FILE"; then
    echo "You already have it setup"
    exit 0
fi

# Check if file exists, if not create it, otherwise append
if [ ! -f "$CLAUDE_FILE" ]; then
    echo "Creating $CLAUDE_FILE..."
    echo "$CONTENT" > "$CLAUDE_FILE"
else
    echo "Appending to existing $CLAUDE_FILE..."
    echo "" >> "$CLAUDE_FILE"
    echo "$CONTENT" >> "$CLAUDE_FILE"
fi

echo "CLAUDE.md file updated successfully!"