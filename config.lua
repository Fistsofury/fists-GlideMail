Config = {}

Config.RegistrationFee = 100 -- Cost to register
Config.SendMessageFee = 10 --Cost to send messages
Config.TimePerMile = 0.1 -- Time in seconds per mile

Config.MailboxLocations = {
    { name = "Annesburg", coords = vector3(2939.47, 1288.51, 44.65) }, 
    { name = "Armadillo", coords = vector3(-3733.91, -2597.8, -12.93) },
    { name = "Blackwater", coords = vector3(-874.91, -1328.74, 43.96) },
    { name = "Rhodes", coords = vector3(1225.58, -1293.97, 76.91) },
    { name = "Saint Denis", coords = vector3(2731.46, -1402.37, 46.18) },  
    { name = "Strawberry", coords = vector3(-1765.2, -384.26, 157.74) },
    { name = "Valentine", coords = vector3(-180.12, 627.28, 114.09) },
    
    -- { name = "Another Location", coords = vector3(x, y, z) },
}

--[[Testing Code
    Config.PropLocations = {
    {x = -187.81, y = 637.49, z = 114.55},--bw
    {x = -869.71, y = -1339.26, z = 43.2},--valentine
}]]
