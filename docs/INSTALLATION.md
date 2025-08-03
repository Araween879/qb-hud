# 📦 Enhanced HUD - Installation Guide

<div align="center">

**🚀 Complete Step-by-Step Installation Guide**

*Follow this guide to get Enhanced HUD running on your FiveM server*

</div>

---

## 📋 **Prerequisites**

Before installing Enhanced HUD, ensure your server meets these requirements:

### 🖥️ **Server Requirements**
- ✅ **FiveM Server** (Latest Recommended Build)
- ✅ **QBCore Framework** (Latest Version)
- ✅ **MySQL Database** (MariaDB 10.3+ or MySQL 8.0+)
- ✅ **oxmysql Resource** (For database connectivity)
- ⚠️ **interact-sound Resource** (Optional, for sound effects)

### 📊 **Minimum System Requirements**
- **RAM:** 512MB available
- **Storage:** 50MB free space
- **Network:** Stable internet connection
- **Operating System:** Windows/Linux server environment

### ⚡ **Recommended System Requirements**
- **RAM:** 1GB+ available
- **Storage:** 100MB+ free space
- **CPU:** Multi-core processor
- **Network:** High-speed connection for better performance

---

## 🚀 **Quick Installation (5 Minutes)**

### 1️⃣ **Download Enhanced HUD**

**Option A: GitHub Release (Recommended)**
```bash
# Download latest release
wget https://github.com/your-repo/enhanced-hud/releases/latest/download/enhanced-hud.zip

# Extract to resources folder
unzip enhanced-hud.zip -d /path/to/server/resources/[qb]/
```

**Option B: Git Clone**
```bash
# Clone repository
cd /path/to/server/resources/[qb]/
git clone https://github.com/your-repo/enhanced-hud.git
```

### 2️⃣ **Add to Server Configuration**
```bash
# Add to server.cfg (order matters!)
ensure oxmysql          # Database connector
ensure qb-core          # QBCore framework
ensure interact-sound   # Sound system (optional)
ensure enhanced-hud     # Enhanced HUD (add last)
```

### 3️⃣ **Start Your Server**
```bash
# Database table will be auto-created on first start
# Players can immediately use /hud to access settings
```

**✅ Basic installation complete! Players can now use the HUD.**

---

## 🔧 **Detailed Installation Process**

### 📁 **Step 1: File Structure Setup**

1. **Navigate to your server resources directory:**
   ```bash
   cd /path/to/your/server/resources/[qb]/
   ```

2. **Create Enhanced HUD directory:**
   ```bash
   mkdir enhanced-hud
   cd enhanced-hud
   ```

3. **Download and extract files:**
   ```bash
   # Method 1: Direct download
   wget https://github.com/your-repo/enhanced-hud/archive/main.zip
   unzip main.zip
   mv enhanced-hud-main/* .
   
   # Method 2: Git clone
   git clone https://github.com/your-repo/enhanced-hud.git .
   ```

4. **Verify file structure:**
   ```
   enhanced-hud/
   ├── fxmanifest.lua       ✅ Main manifest
   ├── config.lua           ✅ Configuration
   ├── client.lua           ✅ Client entry point
   ├── server.lua           ✅ Server entry point
   ├── modules/             ✅ Lua modules directory
   ├── server/              ✅ Server scripts directory
   ├── html/                ✅ NUI frontend directory
   ├── locales/             ✅ Language files
   └── docs/                ✅ Documentation
   ```

### 🗄️ **Step 2: Database Configuration**

#### **Automatic Setup (Recommended)**
Enhanced HUD automatically creates its database table on first startup.

1. **Ensure oxmysql is running:**
   ```bash
   # Check server console for:
   # [oxmysql] Database connected successfully
   ```

2. **Start Enhanced HUD:**
   ```bash
   # The resource will automatically create:
   # - player_hud_settings table
   # - Required indexes
   # - Backup system
   ```

#### **Manual Setup (Advanced)**
If you prefer manual database setup:

```sql
-- Connect to your database
USE your_database_name;

-- Create HUD settings table
CREATE TABLE IF NOT EXISTS player_hud_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL UNIQUE,
    settings JSON NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_citizenid (citizenid)
);

-- Verify table creation
SHOW TABLES LIKE 'player_hud_settings';
DESCRIBE player_hud_settings;
```

### ⚙️ **Step 3: Configuration Setup**

1. **Open config.lua:**
   ```bash
   nano enhanced-hud/config.lua
   ```

2. **Basic configuration:**
   ```lua
   Config = {
       -- Performance (adjust based on server specs)
       UpdateInterval = 250,        -- 250ms = 4 FPS (recommended)
       ReducedAnimations = false,   -- Set true for low-end servers
       
       -- Default theme
       Themes = {
           Default = 'cyberpunk',   -- cyberpunk, synthwave, matrix
       },
       
       -- Enable/disable features
       GpsHud = {
           Enabled = true,
           AutoShow = true,
           Position = 'top-right',
       }
   }
   ```

3. **Performance tuning:**
   ```lua
   -- For high-performance servers (recommended)
   Config.UpdateInterval = 250
   Config.HighQualityEffects = true
   
   -- For mid-range servers
   Config.UpdateInterval = 500
   Config.ReducedAnimations = false
   
   -- For low-end servers
   Config.UpdateInterval = 1000
   Config.ReducedAnimations = true
   Config.HighQualityEffects = false
   ```

### 📡 **Step 4: Server Configuration**

1. **Edit server.cfg:**
   ```bash
   nano /path/to/server.cfg
   ```

2. **Add resources in correct order:**
   ```bash
   # Essential dependencies (load first)
   ensure oxmysql
   ensure qb-core
   ensure qb-target
   ensure qb-inventory
   
   # Optional dependencies
   ensure interact-sound
   
   # Enhanced HUD (load after dependencies)
   ensure enhanced-hud
   
   # Other resources (load after)
   # ensure other-resources
   ```

3. **Restart server or start resource:**
   ```bash
   # In server console:
   ensure enhanced-hud
   
   # Or restart entire server:
   # restart server
   ```

---

## 🔗 **Dependency Setup**

### 📊 **Required Dependencies**

#### **1. QBCore Framework**
```bash
# If not already installed:
cd /path/to/server/resources/[qb]/
git clone https://github.com/qbcore-framework/qb-core.git
```

#### **2. oxmysql Database Connector**
```bash
# Download from GitHub releases:
wget https://github.com/overextended/oxmysql/releases/latest/download/oxmysql.tar.gz
tar -xzf oxmysql.tar.gz -C /path/to/server/resources/
```

### 🔊 **Optional Dependencies**

#### **1. interact-sound (For Sound Effects)**
```bash
cd /path/to/server/resources/
git clone https://github.com/qbcore-framework/interact-sound.git
```

**Configure interact-sound:**
```lua
-- In interact-sound config:
Config.Loop = false
Config.Volume = 0.5
```

#### **2. Additional Integrations**
```bash
# For advanced vehicle integration:
ensure qb-vehiclekeys
ensure qb-fuel

# For stress system integration:
ensure qb-policejob
ensure qb-ambulancejob
```

---

## ✅ **Installation Verification**

### 🧪 **Testing Checklist**

1. **Server Startup Test:**
   ```bash
   # Check server console for:
   ✅ [Enhanced HUD] Module loaded successfully
   ✅ [HUD-PERSISTENCE] Database table ready
   ✅ [Enhanced HUD] Main client.lua loaded successfully
   ```

2. **Client Connection Test:**
   ```bash
   # Player joins server:
   ✅ HUD appears automatically
   ✅ Player stats display correctly
   ✅ No error messages in F8 console
   ```

3. **Functionality Test:**
   ```bash
   # Test commands:
   /hud           # Should open settings menu
   /hudtheme      # Should show theme options
   /hud_debug     # Should toggle debug info (if enabled)
   ```

4. **Database Test:**
   ```sql
   -- Check if settings are saving:
   SELECT * FROM player_hud_settings LIMIT 5;
   
   -- Should show player settings in JSON format
   ```

### 🐛 **Common Installation Issues**

#### **Issue: HUD Not Showing**
```bash
# Solutions:
1. Check resource load order in server.cfg
2. Ensure qb-core loads before enhanced-hud
3. Verify no conflicting HUD resources
4. Check F8 console for JavaScript errors
```

#### **Issue: Settings Not Saving**
```bash
# Solutions:
1. Verify oxmysql is running
2. Check database connection
3. Ensure player_hud_settings table exists
4. Check server console for database errors
```

#### **Issue: Performance Problems**
```lua
-- Increase update intervals:
Config.UpdateInterval = 500  -- Reduce from 250
Config.ReducedAnimations = true
Config.HighQualityEffects = false
```

#### **Issue: Theme Not Loading**
```bash
# Solutions:
1. Clear browser cache (Ctrl+F5)
2. Check CSS file paths in fxmanifest.lua
3. Verify theme files exist
4. Check F8 console for CSS errors
```

---

## 📱 **Mobile & Responsive Setup**

### 📱 **Mobile Optimization**
```lua
-- In config.lua for mobile servers:
Config.Mobile = {
    Enabled = true,
    ReducedSize = true,
    TouchOptimized = true,
    PerformanceMode = true
}
```

### 🖥️ **Multi-Monitor Support**
```lua
-- For users with multiple monitors:
Config.Display = {
    ScaleWithResolution = true,
    MaxWidth = '90vw',
    MaxHeight = '90vh'
}
```

---

## 🔧 **Advanced Configuration**

### 🎨 **Custom Theme Setup**
```css
/* Create custom theme in html/css/themes.css */
.theme-custom {
    --color-primary: #your-color;
    --color-secondary: #your-color;
    --glow-primary: 0 0 20px #your-color;
}
```

### 🔄 **Integration with Other Resources**
```lua
-- Example integration in other resources:
exports['enhanced-hud']:SetTheme('cyberpunk')
exports['enhanced-hud']:ForceStatusUpdate()

-- Check if HUD is ready:
if exports['enhanced-hud']:IsHudReady() then
    -- Your integration code
end
```

### 🛡️ **Security Configuration**
```lua
-- Restrict admin commands:
Config.AdminCommands = {
    RequireAdmin = true,
    AllowedRoles = {'admin', 'owner'},
    LogCommands = true
}
```

---

## 📊 **Performance Optimization**

### ⚡ **Server Performance**
```lua
-- Optimize for server performance:
Config.Performance = {
    UpdateInterval = 500,           -- Higher interval = less CPU
    BatchUpdates = true,            -- Group updates together
    MaxPlayersForEffects = 32,      -- Disable effects with many players
    MemoryCleanup = true            -- Auto cleanup unused data
}
```

### 🎮 **Client Performance**
```lua
-- Optimize for client performance:
Config.Client = {
    RenderDistance = 100,           -- HUD render distance
    LevelOfDetail = 'medium',       -- low, medium, high
    ParticleCount = 25,             -- Reduce particles
    AnimationQuality = 'balanced'   -- minimal, balanced, high
}
```

---

## 🔄 **Update Process**

### 📥 **Updating Enhanced HUD**

1. **Backup current installation:**
   ```bash
   cp -r enhanced-hud enhanced-hud-backup
   ```

2. **Download new version:**
   ```bash
   wget https://github.com/your-repo/enhanced-hud/releases/latest/download/enhanced-hud.zip
   ```

3. **Merge configurations:**
   ```bash
   # Copy your custom config.lua
   cp enhanced-hud-backup/config.lua enhanced-hud/config.lua.backup
   ```

4. **Restart resource:**
   ```bash
   # In server console:
   stop enhanced-hud
   ensure enhanced-hud
   ```

### 🗂️ **Migration Guide**
```lua
-- For updates from older versions:
-- 1. Database migrations are automatic
-- 2. Config file may need manual updates
-- 3. Check CHANGELOG.md for breaking changes
```

---

## 🆘 **Getting Help**

### 📞 **Support Channels**
- 📖 **Documentation:** Check [docs/](docs/) folder
- 🐛 **Bug Reports:** [GitHub Issues](https://github.com/your-repo/enhanced-hud/issues)
- 💬 **Community:** [Discord Server](https://discord.gg/your-discord)
- 📧 **Direct Contact:** support@your-domain.com

### 🔍 **Diagnostic Commands**
```bash
# Generate diagnostic report:
/hud_debug         # Enable debug mode
/hud_status        # Show system status
/hudstats          # Usage statistics (Admin only)

# Check server console for detailed logs
```

### 📝 **Log Analysis**
```bash
# Important log patterns to check:
✅ [Enhanced HUD] Module loaded successfully
✅ [HUD-PERSISTENCE] Database table ready
❌ [HUD-ERROR] Any error messages
⚠️ [HUD-WARNING] Warning messages
```

---

## ✅ **Installation Complete!**

<div align="center">

**🎉 Congratulations! Enhanced HUD is now installed and ready to use! 🎉**

**Next Steps:**
- 🎮 Join your server and test the HUD
- ⚙️ Customize settings via `/hud` command
- 🎨 Try different themes with `/hudtheme`
- 📖 Read the [Configuration Guide](CONFIGURATION.md) for advanced setup

**Need Help?**
- 📖 Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- 💬 Join our [Discord Community](https://discord.gg/your-discord)

</div>