# 🤝 Contributing to Enhanced HUD

Welcome to the Enhanced HUD project! We're excited that you want to contribute to our modular Neon/Cyberpunk HUD system for QBCore. This guide will help you get started with contributing effectively.

## 📋 Table of Contents

- [🎯 Quick Start](#-quick-start)
- [🔧 Development Setup](#-development-setup)
- [📝 Contribution Guidelines](#-contribution-guidelines)
- [🎨 Code Standards](#-code-standards)
- [🧪 Testing Requirements](#-testing-requirements)
- [📚 Documentation Standards](#-documentation-standards)
- [🚀 Pull Request Process](#-pull-request-process)
- [🐛 Bug Reports](#-bug-reports)
- [✨ Feature Requests](#-feature-requests)
- [🏆 Recognition](#-recognition)

---

## 🎯 Quick Start

### 🔥 Priority Contribution Areas

We're particularly looking for help in these areas:

1. **🌍 Translations** - Add new language support
2. **🎨 Themes** - Create new visual themes
3. **🔧 Performance** - Optimize existing code
4. **📱 Mobile Support** - Improve mobile compatibility
5. **🧩 Modules** - Develop new functionality
6. **📚 Documentation** - Improve guides and examples
7. **🐛 Bug Fixes** - Fix issues and improve stability

### ⚡ Quick Contribution

1. 🍴 **Fork** the repository
2. 🌿 **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. 💻 **Make** your changes
4. ✅ **Test** thoroughly
5. 📝 **Submit** a pull request

---

## 🔧 Development Setup

### 📋 Prerequisites

- **FiveM Server** with QBCore Framework
- **Git** for version control
- **Code Editor** (VS Code recommended)
- **Basic Knowledge** of Lua, JavaScript, HTML/CSS

### 🛠️ Environment Setup

```bash
# 1. Fork and clone the repository
git clone https://github.com/YOUR-USERNAME/enhanced-hud.git
cd enhanced-hud

# 2. Create your feature branch
git checkout -b feature/your-feature-name

# 3. Copy to your FiveM resources folder
cp -r . /path/to/your/server/resources/[qb]/enhanced-hud/

# 4. Add to server.cfg
echo "ensure enhanced-hud" >> /path/to/your/server/server.cfg

# 5. Start your server and test
```

### 🎯 Project Structure Understanding

```
📁 enhanced-hud/
├── 📄 fxmanifest.lua               # Resource manifest
├── 📄 config.lua                   # Main configuration
├── 📄 client.lua                   # Main client entry point
├── 📄 server.lua                   # Main server entry point
│
├── 📁 modules/                     # Modular system core
│   ├── hud-events.lua              # Event management
│   ├── hud-settings.lua            # Settings system
│   ├── hud-themes.lua              # Theme engine
│   ├── hud-core.lua                # Status monitoring
│   ├── hud-vehicle.lua             # Vehicle integration
│   ├── hud-map.lua                 # GPS/Compass
│   └── qb-hud-compatibility.lua    # Backward compatibility
│
├── 📁 html/                        # NUI Frontend
│   ├── index.html                  # Main interface
│   ├── style.css                   # ⚠️ Main stylesheet
│   ├── app.js                      # Main app logic
│   ├── 📁 css/                     # Modular CSS
│   └── 📁 js/                      # Modular JavaScript
│
├── 📁 docs/                        # Documentation
└── 📁 locales/                     # Translations
```

---

## 📝 Contribution Guidelines

### 🎯 Types of Contributions

#### 🐛 Bug Fixes
- **Scope:** Fix existing issues
- **Priority:** High
- **Requirements:** Test case, clear description

#### ✨ New Features
- **Scope:** Add new functionality
- **Priority:** Medium
- **Requirements:** Design proposal, documentation

#### 🎨 Themes & UI
- **Scope:** Visual improvements
- **Priority:** Medium
- **Requirements:** Follow Neon UI Master Guide

#### 🌍 Translations
- **Scope:** Language support
- **Priority:** High
- **Requirements:** Native speaker preferred

#### 📚 Documentation
- **Scope:** Improve guides
- **Priority:** Medium
- **Requirements:** Clear, helpful content

### 🚫 What We Don't Accept

- **Breaking Changes** without major version bump
- **Performance Regressions** that hurt user experience
- **Unauthorized Dependencies** not in the approved list
- **Code Without Tests** for critical functionality
- **Poor Documentation** without clear explanations
- **GPL Licensed Code** (MIT License required)

---

## 🎨 Code Standards

### 🐛 Critical Coding Rules

**MUST FOLLOW** the [Critical Coding Rules](README.md#-kritische-coding-regeln) to prevent:
- SQL injection vulnerabilities
- Function call failures
- NUI communication errors
- Data corruption

### 🔤 Lua Code Standards

```lua
-- ✅ Good: Descriptive variable names
local playerStatus = QBCore.Functions.GetPlayerData()
local healthPercentage = GetEntityHealth(PlayerPedId()) / 2

-- ✅ Good: Error handling
if not playerStatus or not playerStatus.metadata then
    print("❌ Player data unavailable")
    return false
end

-- ✅ Good: Type checking
if type(data) ~= "table" then
    print("❌ Invalid data type")
    return
end

-- ✅ Good: Consistent formatting
Config.StatusBars = {
    Health = {
        enabled = true,
        position = { x = 100, y = 50 },
        colors = { primary = '#ff4444', secondary = '#ff0000' }
    }
}
```

### 🌐 JavaScript Code Standards

```javascript
// ✅ Good: Modern ES6+ syntax
const updateStatus = (statusData) => {
    if (!statusData || typeof statusData !== 'object') {
        console.error('❌ Invalid status data');
        return false;
    }
    
    // Use const/let appropriately
    const elements = document.querySelectorAll('.status-bar');
    
    // Proper error handling
    try {
        elements.forEach(element => {
            element.style.width = `${statusData.value}%`;
        });
        return true;
    } catch (error) {
        console.error('❌ Status update failed:', error);
        return false;
    }
};

// ✅ Good: Consistent fetch usage
const sendNUIMessage = async (action, data) => {
    try {
        const response = await fetch(`https://${GetParentResourceName()}/${action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        return await response.json();
    } catch (error) {
        console.error('❌ NUI message failed:', error);
        return null;
    }
};
```

### 🎨 CSS Code Standards

```css
/* ✅ Good: Follow Neon UI Design System */
.hud-component {
    /* Use design tokens */
    background: var(--color-surface);
    border-radius: var(--radius-lg);
    padding: var(--space-4);
    
    /* Proper transitions */
    transition: all var(--anim-normal);
    
    /* Neon effects */
    box-shadow: var(--shadow-hud-item);
    border: 1px solid var(--color-primary);
}

/* ✅ Good: Hover states */
.hud-component:hover {
    transform: scale(1.02);
    box-shadow: var(--shadow-hover);
}

/* ✅ Good: Responsive design */
@media (max-width: 768px) {
    .hud-component {
        padding: var(--space-2);
        font-size: var(--font-size-sm);
    }
}
```

### 📂 File Naming Conventions

- **Lua files:** `kebab-case.lua` (e.g., `hud-settings.lua`)
- **CSS files:** `kebab-case.css` (e.g., `design-tokens.css`)
- **JS files:** `kebab-case.js` (e.g., `state-manager.js`)
- **HTML files:** `kebab-case.html` (e.g., `gps-hud.html`)

---

## 🧪 Testing Requirements

### ✅ Before Submitting

1. **Functionality Testing**
   - Test on clean QBCore server
   - Test all modified features
   - Test with different screen resolutions
   - Test on different performance settings

2. **Performance Testing**
   - Check FPS impact (should be < 2 FPS)
   - Monitor memory usage
   - Test with 32+ players online
   - Verify no console errors

3. **Compatibility Testing**
   - Test with common QBCore resources
   - Test theme switching
   - Test settings persistence
   - Test mobile responsiveness

### 🔍 Test Cases for Common Areas

#### Theme Testing
```lua
-- Test theme switching
ThemeManager.setTheme('cyberpunk')
ThemeManager.setTheme('synthwave')
ThemeManager.setTheme('matrix')

-- Verify no errors in F8 console
-- Check visual consistency
-- Test hover effects and animations
```

#### Status Bar Testing
```lua
-- Test status updates
TriggerEvent('hud:updateStatus', {
    health = 50,
    armor = 75,
    hunger = 25,
    thirst = 90
})

-- Test critical thresholds
-- Test color changes
-- Test animations
```

---

## 📚 Documentation Standards

### 📝 Code Documentation

```lua
--[[
    Function: UpdatePlayerStatus
    Description: Updates all player status bars with new values
    
    @param statusData table - Player status data
    @param forceUpdate boolean - Force immediate update
    @return boolean - Success status
    
    Example:
    local success = UpdatePlayerStatus({
        health = 100,
        armor = 50
    }, true)
]]
function UpdatePlayerStatus(statusData, forceUpdate)
    -- Implementation
end
```

### 📖 Feature Documentation

When adding new features, include:

1. **README.md update** - Add feature to main documentation
2. **API.md update** - Document new exports/events
3. **Configuration example** - Show how to configure
4. **Migration guide** - If breaking changes exist

### 🌍 Translation Guidelines

```lua
-- locales/your_language.lua
Locales['your_lang'] = {
    -- UI Elements
    ['health'] = 'Your Translation',
    ['armor'] = 'Your Translation',
    ['hunger'] = 'Your Translation',
    ['thirst'] = 'Your Translation',
    
    -- Commands
    ['command_hud_debug'] = 'Your Translation',
    ['command_hud_reset'] = 'Your Translation',
    
    -- Messages
    ['hud_initialized'] = 'Your Translation',
    ['settings_saved'] = 'Your Translation',
    ['theme_changed'] = 'Your Translation',
    
    -- Errors
    ['error_invalid_theme'] = 'Your Translation',
    ['error_save_failed'] = 'Your Translation'
}
```

---

## 🚀 Pull Request Process

### 📋 PR Template

Use this template when creating pull requests:

```markdown
## 🎯 Type of Change
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 🎨 UI/Theme improvement
- [ ] 📚 Documentation update
- [ ] 🌍 Translation
- [ ] ⚡ Performance improvement

## 📝 Description
Brief description of changes made.

## 🧪 Testing
- [ ] Tested on clean QBCore server
- [ ] No console errors
- [ ] Performance impact verified
- [ ] Cross-browser tested (if UI changes)

## 📷 Screenshots
(If applicable)

## 🔗 Related Issues
Fixes #(issue number)
```

### ✅ PR Requirements

1. **Clear Title** - Describe what the PR does
2. **Detailed Description** - Explain the changes
3. **Testing Evidence** - Show that it works
4. **No Breaking Changes** - Unless discussed
5. **Documentation Updates** - If needed
6. **Follow Code Standards** - Match existing code style

### 🔄 Review Process

1. **Automated Checks** - Code style, basic tests
2. **Maintainer Review** - Code quality, architecture fit
3. **Community Testing** - Real-world testing
4. **Final Approval** - Merge when ready

---

## 🐛 Bug Reports

### 📋 Bug Report Template

```markdown
**🐛 Bug Description**
Clear description of the bug.

**🔄 Steps to Reproduce**
1. Step one
2. Step two
3. Bug occurs

**✅ Expected Behavior**
What should happen.

**❌ Actual Behavior**
What actually happens.

**🖥️ Environment**
- FiveM Version: 
- QBCore Version: 
- Enhanced HUD Version: 
- Browser: (if UI bug)

**📋 Additional Context**
- Console errors (F8)
- Server console errors
- Related resources
- Screenshots/videos
```

### 🔍 Before Reporting

1. **Check Existing Issues** - Search for similar problems
2. **Update to Latest** - Ensure you're on current version
3. **Test Minimal Setup** - Remove other resources to isolate
4. **Gather Debug Info** - Use `/hud_debug_info` command

---

## ✨ Feature Requests

### 💡 Feature Request Template

```markdown
**✨ Feature Description**
Clear description of the requested feature.

**🎯 Problem/Use Case**
What problem does this solve?

**💭 Proposed Solution**
How should it work?

**🔄 Alternatives Considered**
Other solutions you've thought of.

**📊 Impact Assessment**
- Performance impact
- Compatibility concerns
- Maintenance burden
```

### 🎯 Feature Evaluation Criteria

1. **Alignment** - Fits project vision
2. **Quality** - Maintains code standards
3. **Performance** - Doesn't hurt performance
4. **Maintenance** - Sustainable long-term
5. **Community Value** - Benefits many users

---

## 🏆 Recognition

### 🌟 Contributors

All contributors are recognized in:
- **README.md Credits** section
- **CHANGELOG.md** for each version
- **GitHub Contributors** page
- **Discord Community** announcements

### 🎖️ Contribution Levels

- **🥉 Bronze:** 1-5 merged PRs
- **🥈 Silver:** 6-15 merged PRs
- **🥇 Gold:** 16+ merged PRs
- **💎 Diamond:** Major feature contributions
- **👑 Maintainer:** Ongoing project stewardship

---

## 📞 Getting Help

### 💬 Communication Channels

- **GitHub Issues** - Bug reports, feature requests
- **GitHub Discussions** - General questions
- **Discord Community** - Real-time chat
- **Pull Request Comments** - Code-specific discussions

### 📚 Resources

- **[Installation Guide](docs/INSTALLATION.md)** - Setup instructions
- **[API Documentation](docs/API.md)** - Technical reference
- **[Theme Guide](docs/THEMES.md)** - Theme development
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues

---

## 📄 License

By contributing to Enhanced HUD, you agree that your contributions will be licensed under the MIT License.

---

## 🙏 Thank You

Thank you for contributing to Enhanced HUD! Your efforts help make this project better for the entire FiveM community.

**Made with ❤️ by the Enhanced HUD Community**

---

*Last Updated: August 2025*