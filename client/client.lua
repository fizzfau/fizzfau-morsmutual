ESX = nil
inVehicle = false
valeOn = false
left = false
spawnRadius = 150.0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterCommand('vale', function()
	if not valeOn then
		ESX.TriggerServerCallback('fizzfau-vale:checkMoney', function(data)
			if data then
				TriggerEvent('fizzfau-openGarageMenu')
			else
				exports.mythic_notify:SendAlert('error', 'Bu hizmeti kullanmak için yeterli paranız yok!')
			end
		end)
	else
		exports.mythic_notify:SendAlert('error', 'Yakın zamanda bir vale hizmeti kullandınız!')
	end
end)

RegisterNetEvent('fizzfau-vale:TaskVehicle')
AddEventHandler('fizzfau-vale:TaskVehicle', function(vehicle)
	local coords = GetEntityCoords(PlayerPedId())
	local x,y,z = coords.x, coords.y, coords.z
end)

RegisterCommand('valeindir', function()
	local coords = GetEntityCoords(PlayerPedId())
	local pcoords = GetEntityCoords(fizzPed)
	local dist = GetDistanceBetweenCoords(coords, pcoords, false)
	local vehicle = GetVehiclePedIsIn(fizzPed, true)
	if dist <= 15.0 then
		LeaveIt(vehicle)
	end
	while left do
		Citizen.Wait(250)
		local Xpedcoords = GetEntityCoords(PlayerPedId())
		local Ypedcoords = GetEntityCoords(fizzPed)
		local distPed = GetDistanceBetweenCoords(Xpedcoords, Ypedcoords, false)
		TaskGoToCoordAnyMeans(fizzPed, Xpedcoords.x, Xpedcoords.y, Xpedcoords.z, 1.0, 0, 0, 786603, 1.0)
		if distPed <= 2.3 then
			left = false
			GiveKeysTakeMoney()
		end
	end
end)

RegisterNetEvent('fizzfau-vale:spawnVeh')
AddEventHandler('fizzfau-vale:spawnVeh', function(vehicle, plate)
	SpawnVehicle(vehicle, plate)
end)
function SpawnVehicle(vehicle, plate)
	local coords = GetEntityCoords(PlayerPedId())
  	local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-spawnRadius, spawnRadius), coords.y + math.random(-spawnRadius, spawnRadius), coords.z, 0, 3, 0)
	driverhash = Config.Vale.hash
	print(found)
	RequestModel(vehhash)
	RequestModel(driverhash)
	while not HasModelLoaded(vehhash) and not HasModelLoaded(driverhash) do
		Citizen.Await(0)
	end 
  	if found and HasModelLoaded(driverhash) then
		ESX.Game.SpawnVehicle(vehicle.model, {
			x = spawnPos.x,
			y = spawnPos.y,
			z = spawnPos.z + 1
		}, 180.0, function(callback_vehicle)
			fizz_veh = callback_vehicle
			ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
			SetVehRadioStation(callback_vehicle, "OFF")
			fizzPed = CreatePedInsideVehicle(callback_vehicle, 26, driverhash, -1, true, false) 
			mechBlip = AddBlipForEntity(callback_vehicle)
			SetBlipSprite(mechBlip, 225)                                                      	--Blip Spawning.
			SetBlipFlashes(mechBlip, true) 
			SetBlipColour(mechBlip, 0) 
			Citizen.Wait(5000)
			SetBlipFlashes(mechBlip, false)  
			ClearAreaOfVehicles(GetEntityCoords(callback_vehicle), 5000, false, false, false, false, false);  
			SetVehicleOnGroundProperly(callback_vehicle)
			inVehicle = true
			TaskVehicle(callback_vehicle)
		end)
		TriggerServerEvent('esx_advancedgarage:setVehicleState', plate, false)
		valeOn = true
		
		while valeOn do
			Citizen.Wait(1000)
			if IsPedInVehicle(PlayerPedId(), fizz_veh, true) then
				RemoveBlip(mechBlip)
				valeOn = false
			end
		end
  	end
end

function TaskVehicle(vehicle)
	while inVehicle do
		Citizen.Wait(750)
		local pedcoords = GetEntityCoords(PlayerPedId())
		local plycoords = GetEntityCoords(fizzPed)
		local dist = GetDistanceBetweenCoords(plycoords, pedcoords.x,pedcoords.y,pedcoords.z, false)
		
		if dist <= 25.0 then
			TaskVehicleDriveToCoord(fizzPed, vehicle, pedcoords.x, pedcoords.y, pedcoords.z, 10.0, 1, vehhash, 786603, 5.0, 1)
			SetVehicleFixed(vehicle)
			if dist <= 7.5 then
				LeaveIt(vehicle)
			else
				Citizen.Wait(1000)
			end
		else
			TaskVehicleDriveToCoord(fizzPed, vehicle, pedcoords.x, pedcoords.y, pedcoords.z, 15.0, 1, vehhash, 786603, 5.0, 1)
			Citizen.Wait(1000)
		end
		while left do
			Citizen.Wait(250)
			local Xpedcoords = GetEntityCoords(PlayerPedId())
			local Ypedcoords = GetEntityCoords(fizzPed)
			local distPed = GetDistanceBetweenCoords(Xpedcoords, Ypedcoords, false)
			TaskGoToCoordAnyMeans(fizzPed, Xpedcoords.x, Xpedcoords.y, Xpedcoords.z, 1.0, 0, 0, 786603, 1.0)
			if distPed <= 2.3 then
				left = false
				GiveKeysTakeMoney()
			end
		end
	end
end

function LeaveIt(vehicle)
	TaskLeaveVehicle(fizzPed, vehicle, 14)
	inVehicle = false
	while IsPedInAnyVehicle(fizzPed, false) do
		Citizen.Wait(0)
	end 
	
	Citizen.Wait(500)
	TaskWanderStandard(fizzPed, 10.0, 10)
	left = true
end

function GiveKeysTakeMoney()
	TaskStandStill(fizzPed, 2250)
	TaskTurnPedToFaceEntity(fizzPed, PlayerPedId(), 1.0)
	PlayAmbientSpeech1(fizzPed, "Generic_Hi", "Speech_Params_Force")
	Citizen.Wait(500)
	startPropAnim(fizzPed, "mp_common", "givetake1_a", "p_car_keys_01", 28422)
	Citizen.Wait(250)
	startPropAnim(PlayerPedId(), "mp_common", "givetake1_a", "prop_anim_cash_note_b", 28422)
	Citizen.Wait(1500)
	stopPropAnim(fizzPed, "mp_common", "givetake1_a", "p_car_keys_01")
	stopPropAnim(PlayerPedId(), "mp_common", "givetake1_a", "prop_anim_cash_note_b")

	TaskWanderStandard(fizzPed, 10.0, 10)
	TriggerServerEvent('fizzfau-vale:removeMoney')
	left = false
end

function playAnim(ped, animDict, animName, duration)
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
	TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, duration, 49, 1, false, false, false)
	RemoveAnimDict(animDict)
end

function startPropAnim(ped, dictionary, anim, propname, bone)
	Citizen.CreateThread(function()
	  RequestAnimDict(dictionary)
	  while not HasAnimDictLoaded(dictionary) do
		Citizen.Wait(0)
	  end
		attachObject(ped, propname, bone)
		TaskPlayAnim(ped, dictionary, anim ,8.0, -8.0, -1, 50, 0, false, false, false)
	end)
end

function attachObject(ped, propname, bone)
	prop = CreateObject(GetHashKey(propname), 0, 0, 0, true, true, true)
	AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, bone), 0.05, -0.025, -0.025, 20.0, 180.0, 180.0, true, true, false, true, 1, true)
end

function stopPropAnim(ped, dictionary, anim, propname)
	StopAnimTask(ped, dictionary, anim ,8.0, -8.0, -1, 50, 0, false, false, false)
	DeleteEntity(prop)
end