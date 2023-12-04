FeatherMenu = exports['feather-menu'].initiate()
BccUtils = {}
TriggerEvent('bcc:getUtils', function(bccutils)
    BccUtils = bccutils
end)