# FiveM Starter Pack System

A configurable **ESX starter pack system for FiveM** with Discord booster integration and a modern UI.

![License](https://img.shields.io/badge/license-GPLv3-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)

## ✨ Features

* 🎁 **Fully Configurable Packs** – Add unlimited starter packs via config
* 🔒 **One-Time Claims** – Database tracking prevents duplicate claims
* 💎 **Discord Booster Packs** – Exclusive packs for Discord server boosters
* 🎨 **Modern UI** – Clean, dark-themed interface with search functionality
* 🔔 **ox_lib Notifications** – Clean in-game notifications
* 👨‍💼 **Admin Commands** – Reset starter pack claims
* 📊 **Version Checker** – Automatically checks GitHub for updates

## 📦 Dependencies

* [es_extended](https://github.com/esx-framework/esx_core)
* [ox_lib](https://github.com/overextended/ox_lib)
* [oxmysql](https://github.com/overextended/oxmysql)

## 🛠 Installation

1. Download the latest release
2. Extract it into your `resources` folder
3. Rename the folder to your desired resource name
4. Add the resource to your `server.cfg`:

```cfg
ensure your-resource-name
```

5. Configure `config.lua` with your desired packs
6. Restart your server

> The database table is created automatically on first start.

## ⚙️ Configuration

### Basic Setup

Edit `config.lua` to add or remove starter packs:

```lua
Config.Packs = {
    {
        id = 'starter', -- Unique ID for tracking
        name = 'Starter Pack',
        description = 'Balanced starter bundle for new players.',
        image = '', -- Leave empty or add image URL
        requiresBooster = false,
        rewards = {
            { type = 'item', name = 'WEAPON_PISTOL', amount = 1, label = 'Weapon: Pistol' },
            { type = 'item', name = 'ammo-9', amount = 100, label = '100x Pistol Ammo' },
            { type = 'money', account = 'money', amount = 25000, label = 'CASH: $25,000' },
            { type = 'item', name = 'phone', amount = 1, label = 'Phone' },
            { type = 'item', name = 'radio', amount = 1, label = 'Radio' }
        }
    }
}
```

## 💎 Discord Booster Integration

To enable Discord booster verification:

### 1. Create a Discord Bot

* Go to the Discord Developer Portal
* Create a new application
* Open the **Bot** section and create a bot
* Enable **Server Members Intent** under *Privileged Gateway Intents*
* Copy your bot token

### 2. Add the Bot to Your Server

* Go to **OAuth2 → URL Generator**
* Select scope: `bot`
* Select permission: `Read Messages / View Channels`
* Use the generated URL to invite the bot

### 3. Get Your Server ID

* Enable **Developer Mode** in Discord (User Settings → Advanced)
* Right-click your server → **Copy ID**

### 4. Configure `config.lua`

```lua
Config.DiscordBotToken = 'YOUR_BOT_TOKEN_HERE'
Config.DiscordGuildId = 'YOUR_SERVER_ID_HERE'
```

## 🖼 Images

You have three options for pack images:

### 1. No Image (default icon)

```lua
image = '',
```

### 2. Online Image URL

```lua
image = 'https://i.imgur.com/yourimage.png',
```

### 3. Local Images

* Create an `/images` folder inside the resource
* Add your images
* Reference them in config:

```lua
image = 'nui://your-resource-name/images/weapon.png',
```

**Recommended size:** `512x288` (16:9 aspect ratio)

## ⌨️ Commands

### Player Commands

* `/starterpack` – Open the starter pack menu

### Admin Commands

* `/resetstarterpacks` – Reset your own claims
* `/resetstarterpacks [playerID]` – Reset another player’s claims

> Admin commands require **ESX admin/superadmin** permissions.
> Adjust checks in `server/main.lua` if needed.

## 🎁 Reward Types

### Items

```lua
{ type = 'item', name = 'weapon_pistol', amount = 1, label = 'Pistol' }
```

### Money

**Cash**

```lua
{ type = 'money', account = 'money', amount = 25000, label = 'CASH: $25,000' }
```

**Bank**

```lua
{ type = 'money', account = 'bank', amount = 50000, label = 'BANK: $50,000' }
```

## 🗄 Database

The script automatically creates the following table:

```sql
CREATE TABLE IF NOT EXISTS starter_packs (
    identifier VARCHAR(60) PRIMARY KEY,
    packs_claimed TEXT
);
```

### Manual Reset (if needed)

```sql
DELETE FROM starter_packs;
```

## 🧩 Support

* Open an issue on GitHub for bugs or suggestions
* Please check existing issues before creating a new one

## 📄 License

This project is licensed under the **GPL License**.

## ❤️ Credits

* Built with **ox_lib**
* UI built using **React + TypeScript + TailwindCSS**
* Compatible with **ESX Framework**


