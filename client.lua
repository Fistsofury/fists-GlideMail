local FeatherMenu = exports['feather-menu'].initiate()
local MailboxMenu, RegisterPage, MailActionPage, SendMessagePage, CheckMessagePage, SelectLocationPage
local selectedLocation = ''

-- Function to open the mailbox menu
function OpenMailboxMenu(hasMailbox)
    if not MailboxMenu then
        MailboxMenu = FeatherMenu:RegisterMenu('feather:mailbox:menu', {
            style = {
                ['background-image'] = 'url("nui://fists-GlideMail/Mailtemplate.png")',
                ['background-size'] = 'cover',  
                ['background-repeat'] = 'no-repeat',
                ['height'] = '760px',
            },
            draggable = true
        })
    end
--REGISTRATION PAGE
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
-- MAIL ACTION AKA Send/Check Mail
    if not MailActionPage then
        MailActionPage = MailboxMenu:RegisterPage('mailaction:page')
        MailActionPage:RegisterElement('header', {
            value = 'Mailbox Actions',
            slot = "header",
            style = {
            }
        })

        TextDisplay = MailActionPage:RegisterElement('textdisplay', {
            value = "Pick a option below to Send or view messages.",
            slot = "content",
            style = {}
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
-- Send Message Page
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
        
        SendMessagePage:RegisterElement('input', {
            label = "TO:",
            placeholder = "Mailbox ID ",
            style = {

            }
        }, function(data)
            recipientId = data.value
        end)

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
            style = {

            }
        }, function(data)
            print("recipientId: ", recipientId, "subjectTitle: ", subjectTitle, "mailMessage: ", mailMessage, "selectedLocation: ", selectedLocation)
            TriggerServerEvent("Fists-GlideMail:sendMail", recipientId, subjectTitle, mailMessage, selectedLocation)
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
-- CHECK MESSAGE PAGE
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
--LOCATION CHECK AND BUTTON CREATION
    if not SelectLocationPage then
        SelectLocationPage = MailboxMenu:RegisterPage('selectlocation:page')
        SelectLocationPage:RegisterElement('header', {
            value = 'Select a Location',
            slot = "header"
        })
    
        -- Location Stuff
        for _, location in ipairs(Config.MailboxLocations) do
            SelectLocationPage:RegisterElement('button', {
                label = location.name,
                style = {
                }
            }, function()
                selectedLocation = location.name  
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


RegisterCommand('mailopen', function() -- COMMAND FOR THE MOMENT
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
        TriggerEvent('vorp:TipRight', "Not in the correct location", 4000) -- DISPLAY LOCATION ERROR
    end
end, false)

RegisterNetEvent("Fists-GlideMail:mailboxStatus")
AddEventHandler("Fists-GlideMail:mailboxStatus", function(hasMailbox)
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
            }
        }, function()
            local playerCoords = GetEntityCoords(PlayerPedId())
            local mailLocation = GetMailLocationCoords(mail.location)  
            if IsPlayerAtLocation(playerCoords, mailLocation) then
                OpenMessagePage(mail.message)  
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

function OpenMessagePage(message) -- DISPLAY MESSAGE
    print("Message Content: ", message)
    local MessagePage = MailboxMenu:RegisterPage('message:page')
    MessagePage:RegisterElement('header', {
        value = 'Message Content',
        slot = "header"
    })

    TextDisplay = MessagePage:RegisterElement('textdisplay', {
        value = message,
        slot = "content",
        style = {
            ['color'] = 'black',  
            ['background-color'] = 'white',
            ['font-size'] = '16px'
        }
    })

    MessagePage:RegisterElement('button', {
        label = "Back",
        slot = "footer",
        style = {},
    }, function()
        MailActionPage:RouteTo()  
    end)

    MessagePage:RouteTo()
end

