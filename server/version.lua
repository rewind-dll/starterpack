local RESOURCE_NAME = GetCurrentResourceName()
local CURRENT_VERSION = GetResourceMetadata(RESOURCE_NAME, 'version', 0)
local GITHUB_REPO = 'rewind-dll/starterpack' -- Change this to your GitHub repo (e.g., 'johndoe/starter-packs')

-- Color codes for console
local COLOR_RESET = '^0'
local COLOR_RED = '^1'
local COLOR_GREEN = '^2'
local COLOR_YELLOW = '^3'
local COLOR_BLUE = '^4'

-- Compare version strings (supports semantic versioning)
local function compareVersions(current, latest)
    local function parseVersion(version)
        local major, minor, patch = version:match('(%d+)%.(%d+)%.(%d+)')
        return {
            major = tonumber(major) or 0,
            minor = tonumber(minor) or 0,
            patch = tonumber(patch) or 0
        }
    end
    
    local curr = parseVersion(current)
    local lats = parseVersion(latest)
    
    if lats.major > curr.major then return true end
    if lats.major < curr.major then return false end
    
    if lats.minor > curr.minor then return true end
    if lats.minor < curr.minor then return false end
    
    if lats.patch > curr.patch then return true end
    
    return false
end

-- Check for updates
local function checkVersion()
    if GITHUB_REPO == 'username/repo-name' then
        print(COLOR_YELLOW .. '[' .. RESOURCE_NAME .. '] ^7GitHub repo not configured. Skipping version check.' .. COLOR_RESET)
        return
    end
    
    local endpoint = ('https://api.github.com/repos/%s/releases/latest'):format(GITHUB_REPO)
    
    PerformHttpRequest(endpoint, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            
            if data and data.tag_name then
                local latestVersion = data.tag_name:gsub('v', '') -- Remove 'v' prefix if present
                
                if compareVersions(CURRENT_VERSION, latestVersion) then
                    print('')
                    print(COLOR_YELLOW .. '============================================' .. COLOR_RESET)
                    print(COLOR_YELLOW .. '[' .. RESOURCE_NAME .. '] ^7UPDATE AVAILABLE!' .. COLOR_RESET)
                    print(COLOR_BLUE .. 'Current Version: ^7' .. CURRENT_VERSION .. COLOR_RESET)
                    print(COLOR_GREEN .. 'Latest Version:  ^7' .. latestVersion .. COLOR_RESET)
                    print(COLOR_BLUE .. 'Download: ^7' .. data.html_url .. COLOR_RESET)
                    print(COLOR_YELLOW .. '============================================' .. COLOR_RESET)
                    print('')
                else
                    print(COLOR_GREEN .. '[' .. RESOURCE_NAME .. '] ^7Version up to date! (v' .. CURRENT_VERSION .. ')' .. COLOR_RESET)
                end
            end
        elseif statusCode == 404 then
            print(COLOR_RED .. '[' .. RESOURCE_NAME .. '] ^7GitHub repository not found. Check your GITHUB_REPO setting.' .. COLOR_RESET)
        else
            print(COLOR_RED .. '[' .. RESOURCE_NAME .. '] ^7Failed to check for updates (Status: ' .. statusCode .. ')' .. COLOR_RESET)
        end
    end, 'GET', '', {
        ['User-Agent'] = 'FiveM-Resource-Version-Checker'
    })
end

-- Run version check on resource start
CreateThread(function()
    Wait(1000) -- Wait 1 second after resource start
    checkVersion()
end)
