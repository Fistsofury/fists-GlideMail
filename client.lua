FeatherMenu = exports['feather-menu'].initiate()
local BccUtils = {}
TriggerEvent('bcc:getUtils', function(bccutils)
    BccUtils = bccutils
end)

local MailboxMenu, RegisterPage, MailActionPage, SendMessagePage, CheckMessagePage, SelectLocationPage
local selectedLocation = ''
local LocationETA = ''
local ETADisplay = nil 

local playermailboxId = nil

-- Function to open the mailbox menu
function OpenMailboxMenu(hasMailbox)
    if not MailboxMenu then
        MailboxMenu = FeatherMenu:RegisterMenu('feather:mailbox:menu', {
            style = {
                ['background-image'] = 'url("nui://fists-GlideMail/Mailtemplate.png")',
                ['background-size'] = 'cover',  
                ['background-repeat'] = 'no-repeat',
                    ['background-position'] = 'center',
                    ['background-color'] = 'rgba(55, 33, 14, 0.7)', -- A leather-like brown
                    ['border'] = '1px solid #654321', -- Darker border color
                    ['font-family'] = 'Times New Roman, serif', -- Or another Western-style font if available
                    ['font-size'] = '38px',
                    ['color'] = '#ffffff', -- Off-white text color
                    ['padding'] = '10px 20px',
                    ['margin-top'] = '5px',
                    ['cursor'] = 'pointer', -- If the cursor is supported
                    ['box-shadow'] = '3px 3px #333333', -- Optional, for a pressed-button effect
                    ['text-transform'] = 'uppercase', -- Optional, for a more impactful look
            },
            draggable = true
        })
    end

    if not RegisterPage then
        RegisterPage = MailboxMenu:RegisterPage('register:page')
        RegisterPage:RegisterElement('header', {
            value = 'Mailbox Registration',
            slot = "header"
        })
        
        RegisterPage:RegisterElement('button', {
            label = "Register Mailbox",
            style = {
    
            }
        }, function()
            TriggerServerEvent("Fists-GlideMail:registerMailbox")
        end)
    
    end

    if not MailActionPage then
        MailActionPage = MailboxMenu:RegisterPage('mailaction:page')
        MailActionPage:RegisterElement('header', {
            value = 'Mailbox Actions',
            slot = "header",
            style = {
                ['color'] = '#ffffff',
            }
        })

        MailActionPage:RegisterElement('textdisplay', {
            value = "Your PO BOX number is:" ..playermailboxId,
            style = {
                ['color'] = 'rgb(0, 0, 0)',
            }
        })

        MailActionPage:RegisterElement('button', {
            label = "Send Mail",
            style = {
    
            }
        }, function(data)
            SelectLocationPage:RouteTo()
        end)
    
    
        MailActionPage:RegisterElement('button', {
            label = "Check Mail",
            style = {
                
            }
        }, function()
            TriggerServerEvent("Fists-GlideMail:checkMail")
        end)
    end

    if not SendMessagePage then
        SendMessagePage = MailboxMenu:RegisterPage(`sendmail:page`)
        SendMessagePage:RegisterElement('header', {
            value = 'Send Pigeon',
            slot = "header",
            style = {

            }
        })

        local recipientId = ''
        local mailMessage = ''
        local subjectTitle = ''

        ETADisplay = SendMessagePage:RegisterElement('textdisplay', {
            value = LocationETA,  -- Default value
            style = {
            }
        })
         
        SendMessagePage:RegisterElement('input', {
            label = "TO:",
            placeholder = "PO BOX of recipient",
            style = {

            }
        }, function(data)
            recipientId = data.value
            print("To input: ", LocationETA)
        end)

        SendMessagePage:RegisterElement('textdisplay', {
            value = "Pick a option below to Send or view messages.",
            slot = "content",
            style = {}
        })

        SendMessagePage:RegisterElement('input', {
            label = "Subject",
            placeholder = "Subject title ",
            style = {

            }
        }, function(data)
            subjectTitle = data.value
        end)

    SendMessagePage:RegisterElement('textarea', {
        label = '',
        placeholder = "Type your message here...",
        rows = "6",
        cols = "70",
        resize = true,
        style = {
            ['color'] = 'black',  
            ['background-color'] = 'rgba(255, 255, 255, 0.6)',  
            ['width'] = '80%',
        }

    }, function(data)
        mailMessage = data.value
    end)
    
    SendMessagePage:RegisterElement('button', {
        label = "Send Mail",
        style = {},
    }, function(data)
        print("recipientId: ", recipientId, "subjectTitle: ", subjectTitle, "mailMessage: ", mailMessage, "selectedLocation: ", selectedLocation, "ETA Seconds", LocationETA)
        TriggerServerEvent("Fists-GlideMail:sendMail", recipientId, subjectTitle, mailMessage, selectedLocation, LocationETA)  -- Pass raw ETA seconds
        TriggerEvent('spawnPigeon')
        MailActionPage:RouteTo()
    end)
    end

    SendMessagePage:RegisterElement('button', {
        label = "Back",
        slot = "footer",
        style = {
        },
    }, function()
        SelectLocationPage:RouteTo()
    end)

    if not CheckMessagePage then
        CheckMessagePage = MailboxMenu:RegisterPage('checkmail:page')
        CheckMessagePage:RegisterElement('header', {
            value = 'Received Messages',
            slot = "header",
            style = {
            }
        })
    end

    CheckMessagePage:RegisterElement('button', {
        label = "Back",
        slot = "footer",
        style = {
        },
    }, function()
        MailActionPage:RouteTo()
    end)

    if not SelectLocationPage then
        SelectLocationPage = MailboxMenu:RegisterPage('selectlocation:page')
        SelectLocationPage:RegisterElement('header', {
            value = 'Select a Location',
            slot = "header"
        })

        function CalculateDistanceBetweenCoords(coords1, coords2)
                 return #(coords1 - coords2)  -- Using vector subtraction to get distance
             end
     
                     -- Function to format the ETA
             function FormatTime(seconds)
                 local minutes = math.floor(seconds / 60)
                 local seconds = math.floor(seconds % 60)
                 return string.format("%02d:%02d", minutes, seconds)
             end


    
        -- Location Stuff
        for _, location in ipairs(Config.MailboxLocations) do
            SelectLocationPage:RegisterElement('button', {
                label = location.name,
                style = {},
            }, function()
                selectedLocation = location.name
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = CalculateDistanceBetweenCoords(playerCoords, location.coords)
                local etaSeconds = distance * Config.TimePerMile
                LocationETA = etaSeconds  -- Store raw ETA in seconds
                local formattedETA = FormatTime(etaSeconds)  -- Format for display
        
                -- Update the text display if it's available
                if ETADisplay ~= nil then
                    ETADisplay:update({
                        value = "ETA: " .. formattedETA
                    })
                end
        
                SendMessagePage:RouteTo() 
            end)
        end
    end

    SelectLocationPage:RegisterElement('button', {
        label = "Back",
        slot = "footer",
        style = {
        },
    }, function()
        MailActionPage:RouteTo()
    end)


    if hasMailbox then
        MailboxMenu:Open({ startupPage = MailActionPage })
    else
        MailboxMenu:Open({ startupPage = RegisterPage })
    end
end


RegisterCommand('mailopen', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearMailbox = false

    for _, location in pairs(Config.MailboxLocations) do
        if Vdist(playerCoords, location.coords.x, location.coords.y, location.coords.z) < 10 then -- 10 is the interaction distance
            nearMailbox = true
            break
        end
    end

    if nearMailbox then
        TriggerServerEvent("Fists-GlideMail:checkMailbox")
    else
        TriggerEvent('vorp:TipRight', "Not in the correct location", 4000)
    end
end, false)

RegisterNetEvent("Fists-GlideMail:mailboxStatus")
AddEventHandler("Fists-GlideMail:mailboxStatus", function(hasMailbox, mailboxId)
    playermailboxId = mailboxId
    OpenMailboxMenu(hasMailbox)
end)

RegisterNetEvent("Fists-GlideMail:registerResult")
AddEventHandler("Fists-GlideMail:registerResult", function(success, message)
    if success then
        RegisterPage:RegisterElement('button', {
            label = "Mail Actions"
        }, function()
            MailActionPage:RouteTo()
        end)

    else
    end
end)

RegisterNetEvent("Fists-GlideMail:receiveMails")
AddEventHandler("Fists-GlideMail:receiveMails", function(mails)
    CheckMessagePage = nil
    OpenMailboxMenu(true)  


    for _, mail in ipairs(mails) do
        local buttonLabel = "From: " .. mail.from_char .. " - " .. mail.subject .. " - " .. mail.location
        CheckMessagePage:RegisterElement('button', {
            label = buttonLabel,
            style = {
                -- Button styling
            }
        }, function()
            local playerCoords = GetEntityCoords(PlayerPedId())
            local mailLocation = GetMailLocationCoords(mail.location)
            if IsPlayerAtLocation(playerCoords, mailLocation) then
                OpenMessagePage(mail)  -- Pass the entire mail object
            else
                TriggerEvent('vorp:TipRight', "Not at the correct location", 4000)
            end
        end)
    end

    CheckMessagePage:RouteTo()
end)

function GetMailLocationCoords(locationName)
    for _, loc in ipairs(Config.MailboxLocations) do
        if loc.name == locationName then
            return loc.coords
        end
    end
    return nil  
end

function IsPlayerAtLocation(playerCoords, locationCoords)
    return Vdist(playerCoords, locationCoords.x, locationCoords.y, locationCoords.z) < 10  
end

function OpenMessagePage(mail)
    local MessagePage = MailboxMenu:RegisterPage('message:page')

    MessagePage:RegisterElement('header', {
        value = 'Message Content',
        slot = "header"
    })

    MessagePage:RegisterElement('textdisplay', {
        value = mail.message,  -- Accessing message from the mail object
        style = {
            ['color'] = '#000000',  -- Correcting the color hex code
        }
    })

    MessagePage:RegisterElement('button', {
        label = "Back",
        slot = "footer",
        style = {},
    }, function()
        MailActionPage:RouteTo()  
    end)

    MessagePage:RegisterElement('button', {
        label = "Delete Mail",
        slot = "footer",
        style = {
            ['background-color'] = '#cc0000',
            ['color'] = '#ffffff',  -- Assuming you want white text on a red background
        },
    }, function()
        TriggerServerEvent("Fists-GlideMail:deleteMail", mail.id)  -- Accessing ID from the mail object
        MailActionPage:RouteTo()  
    end)

    MessagePage:RouteTo()
end


RegisterNetEvent('spawnPigeon')
AddEventHandler('spawnPigeon', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local spawnCoords = vector3(playerCoords.x + 0.0, playerCoords.y + 0.0, playerCoords.z + 0.0)
    local model = GetHashKey('A_C_Pigeon')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    local pigeon = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false, true, true)
    TaskFlyAway(pigeon)
    SetModelAsNoLongerNeeded(model)
end)



Citizen.CreateThread(function()
    local model = GetHashKey('mp005_p_mp_shadybirdcage01x')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    local obj = CreateObject(model, -869.71, -1339.26, 43.2, false, false, false)
    SetEntityAsMissionEntity(obj, true, true)
    SetModelAsNoLongerNeeded(model)
end)

