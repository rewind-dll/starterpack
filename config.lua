Config = {}

-- Discord Bot Token for booster verification (leave empty to disable booster check)
Config.DiscordBotToken = ''
Config.DiscordGuildId = '' -- Your Discord Server ID

-- Starter Packs Configuration
Config.Packs = {
    {
        id = 'starter',
        name = 'Starter Pack',
        description = 'Balanced starter bundle for new players.',
        image = 'https://i.imgur.com/civilian-gun.png', -- Replace with your image URLs
        requiresBooster = false,
        rewards = {
            { type = 'item', name = 'WEAPON_PISTOL', amount = 1, label = 'Weapon: Pistol' },
            { type = 'item', name = 'ammo-9', amount = 100, label = '100x PISTOL AMMO' },
            { type = 'money', account = 'money', amount = 25000, label = 'CASH: $25,000' },
            { type = 'item', name = 'radio', amount = 1, label = 'RADIO' },
            { type = 'item', name = 'phone', amount = 1, label = 'PHONE' }
        }
    },
    {
        id = 'booster',
        name = 'Server Booster Pack',
        description = 'Exclusive rewards for Discord boosters.',
        image = 'https://i.imgur.com/booster-gun.png',
        requiresBooster = true,
        rewards = {
            { type = 'item', name = 'WEAPON_SMG', amount = 1, label = 'Weapon: SMG' },
            { type = 'item', name = 'ammo-9', amount = 200, label = '200x SMG AMMO' },
            { type = 'money', account = 'money', amount = 50000, label = 'CASH: $50,000' },
            { type = 'item', name = 'radio', amount = 1, label = 'RADIO' },
            { type = 'item', name = 'phone', amount = 1, label = 'PHONE' }
        }
    }
}
