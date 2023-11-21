local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

-- Event to check for mailbox ID
RegisterNetEvent("Fists-GlideMail:checkMailbox")
AddEventHandler("Fists-GlideMail:checkMailbox", function()
    local _source = source
    local User = VorpCore.getUser(source)
    local Character = User.getUsedCharacter
    local identifier = Character.identifier
    local charidentifier = Character.charIdentifier

    exports.oxmysql:query('SELECT mailbox_id FROM mailboxes WHERE char_identifier = ?', {charidentifier}, function(result)
        if result and #result > 0 then
            TriggerClientEvent("Fists-GlideMail:mailboxStatus", _source, true, result[1].mailbox_id)
        else
            TriggerClientEvent("Fists-GlideMail:mailboxStatus", _source, false, nil)
        end
    end)
end)

RegisterNetEvent("Fists-GlideMail:checkMail")
AddEventHandler("Fists-GlideMail:checkMail", function()
    local _source = source
    local User = VorpCore.getUser(source)
    local Character = User.getUsedCharacter
    local identifier = Character.identifier
    local charidentifier = Character.charIdentifier

    exports.oxmysql:execute('SELECT mailbox_id FROM mailboxes WHERE char_identifier = ?', {charidentifier}, function(result)
        if result and #result > 0 then
            local recipientMailboxId = result[1].mailbox_id
            exports.oxmysql:execute('SELECT * FROM mailbox_messages WHERE to_char = ?', {recipientMailboxId}, function(mails)
                if mails then
                    TriggerClientEvent("Fists-GlideMail:receiveMails", _source, mails)
                else
                    TriggerClientEvent("vorp:TipRight", _source, "No mails found", 5000)
                end
            end)
        else
            TriggerClientEvent("vorp:TipRight", _source, "Mailbox not found", 5000)
        end
    end)
end)


RegisterNetEvent("Fists-GlideMail:registerMailbox")
AddEventHandler("Fists-GlideMail:registerMailbox", function()
    local _source = source
    local User = VorpCore.getUser(source)
    local Character = User.getUsedCharacter
    local identifier = Character.identifier
    local charidentifier = Character.charIdentifier
    local first_name = Character.firstName
    local last_name = Character.lastName


    if Character.money >= Config.RegistrationFee then
        Character.removeCurrency(0, Config.RegistrationFee)

        exports.oxmysql:insert('INSERT INTO mailboxes (char_identifier, first_name, last_name) VALUES (?, ?, ?)', {charidentifier, first_name, last_name}, function(inserted)
            if inserted then
                TriggerClientEvent("Fists-GlideMail:registerResult", _source, true, "Mailbox registered successfully.")
            else
                TriggerClientEvent("Fists-GlideMail:registerResult", _source, false, "Error in mailbox registration.")
            end
        end)
    else
        TriggerClientEvent("vorp:TipRight", _source, "Not enough money to register a mailbox.", 5000)
    end
end)

    

RegisterNetEvent("Fists-GlideMail:sendMail")
AddEventHandler("Fists-GlideMail:sendMail", function(recipientId, subject, message, location)
    local _source = source
    local User = VorpCore.getUser(source)
    local Character = User.getUsedCharacter
    local identifier = Character.identifier
    local charidentifier = Character.charIdentifier

    if Character.money >= Config.SendMessageFee then

        Character.removeCurrency(0, Config.SendMessageFee)

        exports.oxmysql:query('SELECT mailbox_id FROM mailboxes WHERE char_identifier = ?', {charidentifier}, function(senderResult)
            if senderResult and #senderResult > 0 then
                local senderMailboxId = senderResult[1].mailbox_id
                if recipientId and recipientId ~= "" and subject and subject ~= "" and message and message ~= "" and location and location ~= "" then
                    local timestamp = os.date('%Y-%m-%d %H:%M:%S') 
                    exports.oxmysql:insert('INSERT INTO mailbox_messages (from_char, to_char, subject, message, location, timestamp) VALUES (?, ?, ?, ?, ?, ?)', 
                    {senderMailboxId, recipientId, subject, message, location, timestamp}, function(inserted)
                        if inserted then
                            TriggerClientEvent("vorp:TipRight", _source, "You have sent a message", 5000)
                        else
                            TriggerClientEvent("vorp:TipRight", _source, "Failed to send message", 5000)
                        end
                    end)
                else
                    --Support Debugs
                    print("Invalid recipient mailbox ID: " .. tostring(recipientId))
                    print("Invalid message: " .. tostring(message))
                    print("Invalid location: " .. tostring(location))
                    TriggerClientEvent("vorp:TipRight", _source, "Invalid recipient, message, or location", 5000)
                end
            else
                TriggerClientEvent("vorp:TipRight", _source, "Sender mailbox not found", 5000)
            end
        end)
    else
        TriggerClientEvent("vorp:TipRight", _source, "Not enough money to send a message.", 5000)
    end
end)




