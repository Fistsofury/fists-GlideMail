local FeatherMenu = exports['feather-menu'].initiate()
local MailboxMenu, RegisterPage, MailActionPage, SendMessagePage, CheckMessagePage

-- Function to open the mailbox menu
function OpenMailboxMenu(hasMailbox)
    if not MailboxMenu then
        MailboxMenu = FeatherMenu:RegisterMenu('feather:mailbox:menu', {
            style = {
                ['background-image'] = 'url("nui://fists-GlideMail/Mailtemplate.png")',
                ['background-size'] = 'cover',  
                ['background-repeat'] = 'no-repeat'
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
            }
        })
    
        MailActionPage:RegisterElement('button', {
            label = "Send Mail",
            style = {
    
            }
        }, function(data)
            SendMessagePage:RouteTo()
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

        SendMessagePage:RegisterElement('input', {
            label = "Message",
            placeholder = "Type in your message here. ",
            style = {

            }
        }, function(data)
            mailMessage = data.value
        end)
    
    
        SendMessagePage:RegisterElement('button', {
            label = "Send Mail",
            style = {

            }
        }, function(data)
            TriggerServerEvent("Fists-GlideMail:sendMail", recipientId, subjectTitle, mailMessage)
            MailActionPage:RouteTo()
        end)
    end

    if not CheckMessagePage then
        CheckMessagePage = MailboxMenu:RegisterPage('checkmail:page')
        CheckMessagePage:RegisterElement('header', {
            value = 'Received Messages',
            slot = "header",
            style = {
                -- Styling for the header
            }
        })
    end

    -- Open the appropriate page
    if hasMailbox then
        MailboxMenu:Open({ startupPage = MailActionPage })
    else
        MailboxMenu:Open({ startupPage = RegisterPage })
    end
end

-- Handling mailbox interaction
RegisterCommand('mailopen', function()
    -- Check if the player is near any of the mailbox locations
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearMailbox = false

    for _, location in pairs(Config.MailboxLocations) do
        if Vdist(playerCoords, location.x, location.y, location.z) < 10 then -- 10 is the interaction distance
            nearMailbox = true
            break
        end
    end

    if nearMailbox then
        TriggerServerEvent("Fists-GlideMail:checkMailbox")
    else
        -- Optional: Notify the player they are not near a mailbox
    end
end, false)

RegisterNetEvent("Fists-GlideMail:mailboxStatus")
AddEventHandler("Fists-GlideMail:mailboxStatus", function(hasMailbox)
    OpenMailboxMenu(hasMailbox)
end)

RegisterNetEvent("Fists-GlideMail:registerResult")
AddEventHandler("Fists-GlideMail:registerResult", function(success, message)
    if success then
        -- Add "Mail Actions" button to the RegisterPage
        RegisterPage:RegisterElement('button', {
            label = "Mail Actions"
        }, function()
            -- Route to the MailActionPage
            MailActionPage:RouteTo()
        end)

        -- Optional: Display a notification about successful registration
    else
        -- Handle registration failure
        -- ...
    end
end)

RegisterNetEvent("Fists-GlideMail:receiveMails")
AddEventHandler("Fists-GlideMail:receiveMails", function(mails)
    CheckMessagePage:ClearElements()  -- Clear existing elements before adding new ones

    -- Add dynamic elements for each mail
    for _, mail in ipairs(mails) do
        local buttonLabel = "From: " .. mail.from_char .. " - " .. mail.subject
        CheckMessagePage:RegisterElement('button', {
            label = buttonLabel,
            style = {
                -- Button styling
            }
        }, function()
            -- Here you can handle the click event, e.g., show the full message
            -- You might need to fetch the full message details from the server using 'mail.id'
        end)
    end

    -- Optionally, add a back button or other navigation elements

    CheckMessagePage:RouteTo()  -- Display the updated page
end)











------------------------
local FeatherMenu = exports['feather-menu'].initiate()
local MailboxMenu, RegisterPage, MailActionPage, CheckMessagePage

-- Function to open the mailbox menu
function OpenMailboxMenu(hasMailbox)
    local MailboxMenu = FeatherMenu:RegisterMenu('feather:mailbox:menu', {
        style = {
            ['background-image'] = 'url("nui://fists-GlideMail/Mailtemplate.png")',
            ['background-size'] = 'cover',  
            ['background-repeat'] = 'no-repeat'
        },
        draggable = true
    })

    local RegisterPage = MailboxMenu:RegisterPage('register:page')
    local MailActionPage = MailboxMenu:RegisterPage('mailaction:page')
    local SendMessagePage = MailboxMenu:RegisterPage('sendmail:page')
    local CheckMessagePage = MailboxMenu:RegisterPage('checkmail:page')


    ---------------------------------------------------------- Registration Page-------------------------------------------------------------------
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

 -------------------------------------------------------------MAIL ACTION------------------------------------------------------
    MailActionPage:RegisterElement('header', {
        value = 'Mailbox Actions',
        slot = "header",
        style = {
        }
    })

    MailActionPage:RegisterElement('button', {
        label = "Send Mail",
        style = {

        }
    }, function(data)
        SendMessagePage:RouteTo()
    end)


    MailActionPage:RegisterElement('button', {
        label = "Check Mail",
        style = {
            
        }
    }, function()
        TriggerServerEvent("Fists-GlideMail:checkMail")
    end)

       ------------------------------------------------------------------------- -- Mail Send Page--------------------------------------------------------------
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

        SendMessagePage:RegisterElement('input', {
            label = "Message",
            placeholder = "Type in your message here. ",
            style = {

            }
        }, function(data)
            mailMessage = data.value
        end)
    
    
        SendMessagePage:RegisterElement('button', {
            label = "Send Mail",
            style = {

            }
        }, function(data)
            TriggerServerEvent("Fists-GlideMail:sendMail", recipientId, subjectTitle, mailMessage)
            MailActionPage:RouteTo()
        end)

        ---------------------------------------------------------------Check Mail-----------------------------------------------------------------------------
        CheckMessagePage:RegisterElement('header', {
            value = 'Check Mail',
            slot = "header",
            style = {

            }
        })
        
        CheckMessagePage:RegisterElement('input', {
            label = "TO:",
            placeholder = "Mailbox ID ",
            style = {
            }
        }, function()
        end)

        CheckMessagePage:RegisterElement('input', {
            label = "Subject",
            placeholder = "Subject title ",
            style = {

            }
        }, function()
        end)

        CheckMessagePage:RegisterElement('input', {
            label = "Message",
            placeholder = "Type in your message here. ",
            style = {
            }
        }, function()
        end)
    
    
        CheckMessagePage:RegisterElement('button', {
            label = "Send Mail",
            style = {
            }
        }, function()
        end)


    if hasMailbox then
        MailboxMenu:Open({
            startupPage = MailActionPage
        })
    else
        MailboxMenu:Open({
            startupPage = RegisterPage
        })
    end
end



-- Handling mailbox interaction
RegisterCommand('mailopen', function()
    -- Check if the player is near any of the mailbox locations
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearMailbox = false

    for _, location in pairs(Config.MailboxLocations) do
        if Vdist(playerCoords, location.x, location.y, location.z) < 10 then -- 10 is the interaction distance
            nearMailbox = true
            break
        end
    end

    if nearMailbox then
        TriggerServerEvent("Fists-GlideMail:checkMailbox")
    else
        -- Optional: Notify the player they are not near a mailbox
    end
end, false)

-- Receiving mailbox status from server and opening the menu
RegisterNetEvent("Fists-GlideMail:mailboxStatus")
AddEventHandler("Fists-GlideMail:mailboxStatus", function(hasMailbox)
    OpenMailboxMenu(hasMailbox)
end)

RegisterNetEvent("Fists-GlideMail:registerResult")
AddEventHandler("Fists-GlideMail:registerResult", function(success, message)
    if success then
        -- Add "Mail Actions" button to the RegisterPage
        RegisterPage:RegisterElement('button', {
            label = "Mail Actions"
        }, function()
            -- Route to the MailActionPage
            MailActionPage:RouteTo()
        end)

        -- Optional: Display a notification about successful registration
    else
        -- Handle registration failure
        -- ...
    end
end)

RegisterNetEvent("Fists-GlideMail:receiveMails")
AddEventHandler("Fists-GlideMail:receiveMails", function(mails)
    CheckMessagePage:ClearElements()  -- Assuming you have a method to clear existing elements

    for _, mail in ipairs(mails) do
        local buttonLabel = "From: " .. mail.from_char .. " - " .. mail.subject
        CheckMessagePage:RegisterElement('button', {
            label = buttonLabel
            -- style
        }, function()
            -- Here you can open the message, you might need another page or overlay to display the full message
            -- You can pass 'mail.id' to fetch the full message from the server
        end)
    end

    CheckMessagePage:RouteTo()
end)



