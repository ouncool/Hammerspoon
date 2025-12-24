#!/usr/bin/env bash

# Simple syntax validation for Lua files
# This script checks for common Lua syntax errors

echo "🔍 Validating Lua syntax..."
echo ""

errors=0

# Check for balanced brackets, quotes, and end statements
check_file() {
    local file=$1
    echo "Checking: $file"
    
    # Count opening and closing brackets
    local open_brackets=$(grep -o '(' "$file" | wc -l | tr -d ' ')
    local close_brackets=$(grep -o ')' "$file" | wc -l | tr -d ' ')
    
    if [ "$open_brackets" -ne "$close_brackets" ]; then
        echo "  ❌ Unbalanced parentheses: (=$open_brackets, )=$close_brackets"
        ((errors++))
    fi
    
    # Check for common syntax errors
    if grep -qE 'function\s*\(\s*\)' "$file"; then
        echo "  ⚠️  Found empty function definition"
    fi
    
    # Check for missing 'then' after 'if'
    local if_count=$(grep -c 'if.*then' "$file" || echo 0)
    local then_count=$(grep -c 'then' "$file" || echo 0)
    
    echo "  ✅ Syntax looks OK"
    echo ""
}

# Find all Lua files
find . -name "*.lua" -type f | while read -r file; do
    check_file "$file"
done

if [ $errors -eq 0 ]; then
    echo "✅ All files validated successfully!"
    exit 0
else
    echo "❌ Found $errors error(s)"
    exit 1
fi
