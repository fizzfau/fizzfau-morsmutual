ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('fizzfau-vale:removeMoney')
AddEventHandler('fizzfau-vale:removeMoney', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.Vale.price)
end)

ESX.RegisterServerCallback('fizzfau-vale:checkMoney', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.Vale.price then
		cb(true)
	else
		cb(false)
	end
end)