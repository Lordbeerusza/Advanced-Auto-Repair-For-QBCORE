Config = {}

-- Repair locations
Config.RepairLocations = {
    {coords = vector3(-325.13, -139.87, 38.38)}, -- LS Customs 
    {coords = vector3(888.22, -2101.73, 29.84)}, -- Example Location 1 
    {coords = vector3(1181.12, 2650.3, 37.82)}, -- Example Location 2 -- Add more locations as needed }
    -- Add more locations as needed
}

-- Repair settings
Config.RepairRadius = 5.0  -- Radius around the location to trigger the repair prompt
Config.CostMultiplier = 1000  -- Cost scaling factor for repairs
Config.MaxEngineHealth = 1000.0
Config.MaxBodyHealth = 1000.0