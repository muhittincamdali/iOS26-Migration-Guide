#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# iOS 26 Auto-Migration Script
# ═══════════════════════════════════════════════════════════════════════════════
# 
# This script automatically migrates common deprecated patterns to iOS 26 equivalents.
# 
# WARNING: Always review changes before committing!
# This script creates backups before making changes.
#
# Usage: ./auto-migrate.sh /path/to/project [--dry-run] [--no-backup]
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_PATH="${1:-.}"
DRY_RUN=false
NO_BACKUP=false
BACKUP_DIR=""
CHANGES_MADE=0

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --no-backup)
            NO_BACKUP=true
            ;;
    esac
done

# Print banner
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           iOS 26 AUTO-MIGRATION TOOL v1.0                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}"
    echo ""
fi

# Verify project path
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}❌ Error: Directory not found: $PROJECT_PATH${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Project: $PROJECT_PATH${NC}"
echo ""

# Create backup
create_backup() {
    if [ "$NO_BACKUP" = false ] && [ "$DRY_RUN" = false ]; then
        BACKUP_DIR="$PROJECT_PATH/.ios26-migration-backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "${BLUE}📦 Creating backup at: $BACKUP_DIR${NC}"
        mkdir -p "$BACKUP_DIR"
        find "$PROJECT_PATH" -name "*.swift" -exec cp {} "$BACKUP_DIR" \;
        echo -e "${GREEN}✅ Backup created${NC}"
        echo ""
    fi
}

# Helper function to perform replacement
perform_replacement() {
    local pattern="$1"
    local replacement="$2"
    local description="$3"
    local file_pattern="${4:-*.swift}"
    
    local count=0
    
    if [ "$DRY_RUN" = true ]; then
        count=$(grep -rl "$pattern" "$PROJECT_PATH" --include="$file_pattern" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$count" -gt 0 ]; then
            echo -e "${YELLOW}📝 Would replace: $description${NC}"
            echo "   Pattern: $pattern"
            echo "   Replacement: $replacement"
            echo "   Files affected: $count"
            echo ""
            CHANGES_MADE=$((CHANGES_MADE + count))
        fi
    else
        # Perform actual replacement
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            find "$PROJECT_PATH" -name "$file_pattern" -type f -exec grep -l "$pattern" {} \; 2>/dev/null | while read -r file; do
                sed -i '' "s|$pattern|$replacement|g" "$file"
                count=$((count + 1))
            done
        else
            # Linux
            find "$PROJECT_PATH" -name "$file_pattern" -type f -exec grep -l "$pattern" {} \; 2>/dev/null | while read -r file; do
                sed -i "s|$pattern|$replacement|g" "$file"
                count=$((count + 1))
            done
        fi
        
        count=$(grep -rl "$replacement" "$PROJECT_PATH" --include="$file_pattern" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$count" -gt 0 ]; then
            echo -e "${GREEN}✅ Replaced: $description ($count files)${NC}"
            CHANGES_MADE=$((CHANGES_MADE + count))
        fi
    fi
}

# Create backup before starting
create_backup

echo "═══════════════════════════════════════════════════════════════"
echo "🔄 Starting Migration..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# SWIFTUI MIGRATIONS
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}📱 SwiftUI Migrations${NC}"
echo "───────────────────────────────────────────────────────────────"

# NavigationView → NavigationStack
perform_replacement \
    "NavigationView {" \
    "NavigationStack {" \
    "NavigationView → NavigationStack"

# .navigationBarTitle → .navigationTitle
perform_replacement \
    ".navigationBarTitle(" \
    ".navigationTitle(" \
    ".navigationBarTitle → .navigationTitle"

# @StateObject → @State (partial - needs review)
perform_replacement \
    "@StateObject private var" \
    "@State private var" \
    "@StateObject → @State (review needed for @Observable)"

perform_replacement \
    "@StateObject var" \
    "@State var" \
    "@StateObject → @State (review needed for @Observable)"

# @ObservedObject → direct observation
perform_replacement \
    "@ObservedObject var" \
    "var" \
    "@ObservedObject → direct observation (add @Observable to class)"

# @EnvironmentObject → @Environment
perform_replacement \
    "@EnvironmentObject var" \
    "@Environment() var" \
    "@EnvironmentObject → @Environment (add type parameter)"

# Material to Glass
perform_replacement \
    ".ultraThinMaterial" \
    ".glassEffect(.subtle)" \
    ".ultraThinMaterial → .glassEffect(.subtle)"

perform_replacement \
    ".thinMaterial" \
    ".glassEffect(.light)" \
    ".thinMaterial → .glassEffect(.light)"

perform_replacement \
    ".regularMaterial" \
    ".glassEffect()" \
    ".regularMaterial → .glassEffect()"

perform_replacement \
    ".thickMaterial" \
    ".glassEffect(.prominent)" \
    ".thickMaterial → .glassEffect(.prominent)"

echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# UIKIT MIGRATIONS
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}🖼️ UIKit Migrations${NC}"
echo "───────────────────────────────────────────────────────────────"

# UIScreen.main → windowScene
perform_replacement \
    "UIScreen.main.bounds" \
    "view.window?.windowScene?.screen.bounds ?? .zero" \
    "UIScreen.main.bounds → windowScene"

perform_replacement \
    "UIScreen.main.scale" \
    "view.window?.windowScene?.screen.scale ?? 1.0" \
    "UIScreen.main.scale → windowScene"

# Appearance proxy warnings
echo -e "${YELLOW}⚠️  Note: UINavigationBar.appearance() and UITabBar.appearance() need manual migration${NC}"
echo "   See: docs/uikit-changes.md"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# CONCURRENCY MIGRATIONS
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}⚡ Concurrency Patterns${NC}"
echo "───────────────────────────────────────────────────────────────"

# DispatchQueue.main.async → MainActor (comment suggestion)
echo -e "${YELLOW}⚠️  Manual review needed: DispatchQueue.main.async → @MainActor${NC}"
echo "   Run: grep -rn 'DispatchQueue.main.async' $PROJECT_PATH --include='*.swift'"
echo ""

echo -e "${YELLOW}⚠️  Manual review needed: Completion handlers → async/await${NC}"
echo "   Run: grep -rn '@escaping.*Void' $PROJECT_PATH --include='*.swift'"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# PROJECT CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}⚙️ Project Configuration${NC}"
echo "───────────────────────────────────────────────────────────────"

# Update Package.swift if exists
if [ -f "$PROJECT_PATH/Package.swift" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}📝 Would update Package.swift deployment target${NC}"
    else
        # Update iOS deployment target
        if grep -q "\.iOS(.v" "$PROJECT_PATH/Package.swift"; then
            sed -i '' 's/\.iOS(\.v[0-9]*)/\.iOS(\.v26)/g' "$PROJECT_PATH/Package.swift"
            echo -e "${GREEN}✅ Updated Package.swift iOS deployment target to v26${NC}"
        fi
        
        # Update Swift version
        if grep -q "swiftLanguageVersions:" "$PROJECT_PATH/Package.swift"; then
            sed -i '' 's/swiftLanguageVersions: \[\.v[0-9]*\]/swiftLanguageVersions: [.v6]/g' "$PROJECT_PATH/Package.swift"
            echo -e "${GREEN}✅ Updated Package.swift Swift version to v6${NC}"
        fi
    fi
fi

# Check for Podfile
if [ -f "$PROJECT_PATH/Podfile" ]; then
    echo -e "${YELLOW}⚠️  Podfile found - manually update: platform :ios, '26.0'${NC}"
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════════════"
echo "📊 Migration Summary"
echo "═══════════════════════════════════════════════════════════════"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN COMPLETE${NC}"
    echo "Files that would be modified: $CHANGES_MADE"
    echo ""
    echo "Run without --dry-run to apply changes:"
    echo "  ./auto-migrate.sh $PROJECT_PATH"
else
    echo -e "${GREEN}MIGRATION COMPLETE${NC}"
    echo "Files modified: $CHANGES_MADE"
    if [ -n "$BACKUP_DIR" ]; then
        echo ""
        echo "Backup location: $BACKUP_DIR"
        echo "To restore: cp $BACKUP_DIR/* $PROJECT_PATH"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📋 Next Steps"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "1. Review all changes with: git diff"
echo "2. Run the deprecation scanner: swift scripts/deprecation-scanner.swift $PROJECT_PATH"
echo "3. Fix remaining manual migrations"
echo "4. Build and test your project"
echo "5. Run UI tests on iOS 26 simulator"
echo ""
echo "For detailed migration guide, visit:"
echo "https://github.com/muhittincamdali/iOS26-Migration-Guide"
echo ""
