local mailboxMenu, registerPage, mailActionPage, sendMessagePage, checkMessagePage, selectLocationPage
local selectedLocation, locationETA, etaDisplay, playerMailBoxId = '', '', nil, nil

-- Function to open the mailbox menu
local function OpenMailboxMenu(hasMailbox)
    sendMessagePage = nil
    checkMessagePage = nil
    selectLocationPage = nil
    if playerMailBoxId == nil then
        playerMailBoxId = "Not Registered"
    end
    if not mailboxMenu then
        mailboxMenu = nil
        mailboxMenu = FeatherMenu:RegisterMenu('feather:mailbox:menu', {
            style = {
                ['background-image'] = 'url("nui://fists-GlideMail/Mailtemplate.png")',
                ['background-size'] = 'cover',
                ['background-repeat'] = 'no-repeat',
                ['background-position'] = 'center',
                ['background-color'] = 'rgba(55, 33, 14, 0.7)', -- A leather-like brown
                ['border'] = '1px solid #654321',
                ['font-family'] = 'Times New Roman, serif',
                ['font-size'] = '38px',
                ['color'] = '#ffffff',
                ['padding'] = '10px 20px',
                ['margin-top'] = '5px',
                ['cursor'] = 'pointer',
                ['box-shadow'] = '3px 3px #333333',
                ['text-transform'] = 'uppercase'
            },
            draggable = true,
        })
    end

    if not registerPage then
        registerPage = mailboxMenu:RegisterPage('register:page')
        registerPage:RegisterElement('header', {
            value = 'Mailbox Registration',
            slot = "header",
            style = {
                ['font-family'] = 'Times New Roman, serif',
                ['text-transform'] = 'uppercase',
                ['color'] = 'rgb(0, 0, 0)'
            }
        })

        registerPage:RegisterElement('button', {
            label = "Register Mailbox",
            style = {
            }
        }, function()
            TriggerServerEvent("Fists-GlideMail:registerMailbox")
            mailActionPage:RouteTo()
        end)
    end

    if not mailActionPage then
        mailActionPage = mailboxMenu:RegisterPage('mailaction:page')
        mailActionPage:RegisterElement('header', {
            value = 'Mailbox Options',
            slot = "header",
            style = {
                ['font-family'] = 'Times New Roman, serif', 
                ['text-transform'] = 'uppercase', 
                ['color'] = 'rgb(0, 0, 0)',
            }
        })

        mailboxDisplay = mailActionPage:RegisterElement('textdisplay', {
            value = "Your PO BOX number is:" ..playerMailBoxId,
            style = {
                ['color'] = 'rgb(0, 0, 0)',
            }
        })

        mailActionPage:RegisterElement('button', {
            label = "Send Mail",
            style = {

            }
        }, function(data)
            selectLocationPage:RouteTo()
        end)


        mailActionPage:RegisterElement('button', {
            label = "Check Mail",
            style = {
            }
        }, function()
            TriggerServerEvent("Fists-GlideMail:checkMail")
        end)
    end

    if not sendMessagePage then
        sendMessagePage = mailboxMenu:RegisterPage('sendmail:page')
        sendMessagePage:RegisterElement('header', {
            value = 'Send Pigeon',
            slot = "header",
            style = {
                ['font-family'] = 'Times New Roman, serif', 
                ['text-transform'] = 'uppercase', 
                ['color'] = 'rgb(0, 0, 0)',
            }
        })

        local recipientId, mailMessage, subjectTitle = '','',''

        etaDisplay = sendMessagePage:RegisterElement('textdisplay', {
            value = locationETA,
            style = {
                ['font-family'] = 'Times New Roman, serif', 
                ['text-transform'] = 'uppercase', 
                ['color'] = 'rgb(0, 0, 0)',
            }
        })

        sendMessagePage:RegisterElement('input', {
            label = "TO:",
            placeholder = "PO BOX of recipient",
            persist = false,
            style = {

            }
        }, function(data)
            recipientId = data.value
            print("To input: ", locationETA)
        end)

        sendMessagePage:RegisterElement('textdisplay', {
            value = "Pick a option below to Send or view messages.",
            persist = false,
            slot = "content",
            style = {}
        })

        sendMessagePage:RegisterElement('input', {
            persist = false,
            label = "Subject",
            placeholder = "Subject title ",
            style = {

            }
        }, function(data)
            subjectTitle = data.value
        end)

    sendMessagePage:RegisterElement('textarea', {
        --label = 'Message',
        persist = false,
        placeholder = "Type your message here...",
        rows = "6",
        cols = "45",
        resize = true,
        style = {
            ['background-color'] = 'rgba(255, 255, 255, 0.6)',
        }

    }, function(data)
        mailMessage = data.value
    end)

    sendMessagePage:RegisterElement('button', {
        label = "Send Mail",
        style = {},
    }, function(data)
        print("recipientId: ", recipientId, "subjectTitle: ", subjectTitle, "mailMessage: ", mailMessage, "selectedLocation: ", selectedLocation, "ETA Seconds", locationETA)
        TriggerServerEvent("Fists-GlideMail:sendMail", recipientId, subjectTitle, mailMessage, selectedLocation, locationETA)  -- Pass raw ETA seconds
        TriggerEvent('spawnPigeon')

        mailActionPage:RouteTo()
    end)
    end

    sendMessagePage:RegisterElement('button', {
        label = "Back",
        style = {
            ['background-color'] = 'rgb(226, 0, 0)',
            ['color'] = 'rgb(226, 0, 0)',
        },
    }, function()
        selectLocationPage:RouteTo()
    end)


    if not checkMessagePage then
        checkMessagePage = mailboxMenu:RegisterPage('checkmail:page')
        checkMessagePage:RegisterElement('header', {
            value = 'Received Messages',
            slot = "header",
            style = {
                ['font-family'] = 'Times New Roman, serif',
                ['text-transform'] = 'uppercase', 
                ['color'] = 'rgb(0, 0, 0)'
            }
        })
    end

    checkMessagePage:RegisterElement('button', {
        label = "Back",
        persist = false,
        style = {
            ['background-color'] = 'rgb(226, 0, 0)',
            ['color'] = 'rgb(226, 0, 0)'
        },
    }, function()
        mailActionPage:RouteTo()
    end)

    if not selectLocationPage then
        selectLocationPage = mailboxMenu:RegisterPage('selectlocation:page')
        selectLocationPage:RegisterElement('header', {
            value = 'Select a Location',
            slot = "header",
            style = {
                ['font-family'] = 'Times New Roman, serif',
                ['text-transform'] = 'uppercase',
                ['color'] = 'rgb(0, 0, 0)'
            }
        })

        -- Location Stuff
        for key, location in ipairs(Config.MailboxLocations) do
            selectLocationPage:RegisterElement('button', {
                label = location.name,
                style = {},
            }, function()
                selectedLocation = location.name
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - location.coords)
                local etaSeconds = distance * Config.TimePerMile
                locationETA = tostring(etaSeconds)  -- Store raw ETA in seconds
                local formattedETA = string.format("%02d:%02d", math.floor(etaSeconds / 60), math.floor(etaSeconds % 60))

                if etaDisplay ~= nil then
                    etaDisplay:update({
                        value = "ETA: " .. formattedETA
                    })
                end

                sendMessagePage:RouteTo()
            end)
        end
    end

    selectLocationPage:RegisterElement('button', {
        label = "Back",
        style = {
            ['background-color'] = 'rgb(226, 0, 0)',
            ['color'] = 'rgb(226, 0, 0)',
        },
    }, function()
        mailActionPage:RouteTo()
    end)

    if hasMailbox then
        mailboxMenu:Open({ startupPage = mailActionPage })
    else
        mailboxMenu:Open({ startupPage = registerPage })
    end
end

RegisterNetEvent("Fists-GlideMail:mailboxStatus")
AddEventHandler("Fists-GlideMail:mailboxStatus", function(hasMailbox, mailboxId)
    playerMailBoxId = mailboxId
    OpenMailboxMenu(hasMailbox)
end)

RegisterNetEvent("Fists-GlideMail:registerResult")
AddEventHandler("Fists-GlideMail:registerResult", function(success, message)
    if success then
        registerPage:RegisterElement('button', {
            label = "Mail Actions"
        }, function()
            mailActionPage:RouteTo()
        end)
    end
end)

RegisterNetEvent("Fists-GlideMail:updateMailboxId")
AddEventHandler("Fists-GlideMail:updateMailboxId", function(newMailboxId)
    playerMailBoxId = newMailboxId -- Update the playerMailBoxId variable
    if mailboxDisplay ~= nil then
        mailboxDisplay:update({
            value = "Your PO BOX number is:" .. playerMailBoxId
        })
    end
end)

RegisterNetEvent("Fists-GlideMail:receiveMails")
AddEventHandler("Fists-GlideMail:receiveMails", function(mails)
    checkMessagePage = nil
    OpenMailboxMenu(true)


    for key, mail in ipairs(mails) do
        local buttonLabel = "From: " .. mail.from_char .. " - " .. mail.subject .. " - " .. mail.location
        checkMessagePage:RegisterElement('button', {
            label = buttonLabel,
            style = {
                -- Button styling
            }
        }, function()
            local playerCoords = GetEntityCoords(PlayerPedId())
            local mailLocation = GetMailLocationCoords(mail.location)
            if IsPlayerAtLocation(playerCoords, mailLocation) then
                OpenMessagePage(mail)
            else
                TriggerEvent('vorp:TipRight', "Not at the correct location", 4000)
            end
        end)
    end

    checkMessagePage:RouteTo()
end)

function GetMailLocationCoords(locationName)
    for key, loc in ipairs(Config.MailboxLocations) do
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
    local messagePage = mailboxMenu:RegisterPage('message:page')

    messagePage:RegisterElement('header', {
        value = 'Message Content',
        slot = "header",
        style = {
            ['font-family'] = 'Times New Roman, serif', 
            ['text-transform'] = 'uppercase', 
            ['color'] = 'rgb(0, 0, 0)',
        }
    })

    messagePage:RegisterElement('textdisplay', {
        value = mail.message,
        style = {
            ['color'] = '#000000',
            ['max-height'] = '200px',  -- Fixed maximum height
            ['overflow-y'] = 'auto',   -- Allows vertical scrolling
            ['overflow-x'] = 'hidden', -- Prevents horizontal scrolling
            -- Other styling properties as needed
        }
    })

    messagePage:RegisterElement('button', {
        label = "Back",
        slot = "footer",
        style = {
            ['background-color'] = 'rgb(226, 0, 0)',
            ['color'] = 'rgb(226, 0, 0)',
        },
    }, function()
        mailActionPage:RouteTo()
    end)

    messagePage:RegisterElement('button', {
        label = "Delete Mail",
        slot = "footer",
        style = {
            ['background-color'] = '#cc0000',
            ['color'] = '#ffffff',
        },
    }, function()
        TriggerServerEvent("Fists-GlideMail:deleteMail", mail.id)
        mailActionPage:RouteTo()
    end)

    messagePage:RouteTo()
end

RegisterNetEvent('spawnPigeon')
AddEventHandler('spawnPigeon', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local spawnCoords = vector3(playerCoords.x + 0.0, playerCoords.y + 0.0, playerCoords.z + 0.0)
    local model = joaat('A_C_Pigeon')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end
    local pigeon = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false, true, true)
    TaskFlyAway(pigeon)
    SetModelAsNoLongerNeeded(model)
end)

CreateThread(function()
    local promptGroup = BccUtils.Prompt:SetupPromptGroup()
    local mailboxPrompt = nil

    local function registerMailboxPrompt()
        if mailboxPrompt then
            mailboxPrompt:DeletePrompt()
        end
        mailboxPrompt = promptGroup:RegisterPrompt("Open Mailbox", 0x4CC0E2FE, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    end

    for key, location in ipairs(Config.MailboxLocations) do
        local x, y, z = table.unpack(location.coords)
        local blip = BccUtils.Blip:SetBlip('Glide Mail', 'blip_ambient_delivery', 0.2, x, y, z)
    end

    while true do
        Wait(5)
        local playerCoords, nearMailbox = GetEntityCoords(PlayerPedId()), false

        for key, location in pairs(Config.MailboxLocations) do
            if Vdist(playerCoords, location.coords.x, location.coords.y, location.coords.z) < 2 then
                nearMailbox = true
                break
            end
        end

        if nearMailbox then
            if not mailboxPrompt then
                registerMailboxPrompt()
            end
            promptGroup:ShowGroup("Near Mailbox")

            if mailboxPrompt:HasCompleted() then
                TriggerServerEvent("Fists-GlideMail:checkMailbox")
                registerMailboxPrompt()
            end
        else
            if mailboxPrompt then
                mailboxPrompt:DeletePrompt()
                mailboxPrompt = nil
            end
        end
    end
end)