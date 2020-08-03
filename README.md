# fizzfau-morsmutual
Simple Mors Mutual Script Used With esx_advancedgarage

// Attention \\

You need to change some functions and add some events in esx_advancedgarage as I publish here

RegisterNetEvent('fizzfau-openGarageMenu')
AddEventHandler("fizzfau-openGarageMenu", function()
    OpenMenuGarage('fizzfau')
end)

function OpenMenuGarage(PointType)
	ESX.UI.Menu.CloseAll()
	
	local elements = {}
	
	if PointType == 'car_garage_point' then
		table.insert(elements, {label = _U('list_owned_cars'), value = 'list_owned_cars'})
		table.insert(elements, {label = _U('store_owned_cars'), value = 'store_owned_cars'})
	elseif PointType == 'fizzfau' then
		table.insert(elements, {label = _U('list_owned_cars'), value = 'list_owned_cars2'})
		table.insert(elements, {label = _U('return_owned_cars').." ($"..Config.CarPoundPrice..")", value = 'return_owned_cars2'})
	elseif PointType == 'boat_garage_point' then
		table.insert(elements, {label = _U('list_owned_boats'), value = 'list_owned_boats'})
	elseif PointType == 'aircraft_garage_point' then
		table.insert(elements, {label = _U('list_owned_aircrafts'), value = 'list_owned_aircrafts'})
	elseif PointType == 'car_store_point' then
		table.insert(elements, {label = _U('store_owned_cars'), value = 'store_owned_cars'})
	elseif PointType == 'boat_store_point' then
		table.insert(elements, {label = _U('store_owned_boats'), value = 'store_owned_boats'})
	elseif PointType == 'aircraft_store_point' then
		table.insert(elements, {label = _U('store_owned_aircrafts'), value = 'store_owned_aircrafts'})
	elseif PointType == 'car_pound_point' then
		table.insert(elements, {label = _U('return_owned_cars').." ($"..Config.CarPoundPrice..")", value = 'return_owned_cars'})
	elseif PointType == 'boat_pound_point' then
		table.insert(elements, {label = _U('return_owned_boats').." ($"..Config.BoatPoundPrice..")", value = 'return_owned_boats'})
	elseif PointType == 'aircraft_pound_point' then
		table.insert(elements, {label = _U('return_owned_aircrafts').." ($"..Config.AircraftPoundPrice..")", value = 'return_owned_aircrafts'})
	elseif PointType == 'policing_pound_point' then
		table.insert(elements, {label = _U('return_owned_policing').." ($"..Config.PolicingPoundPrice..")", value = 'return_owned_policing'})
	elseif PointType == 'ambulance_pound_point' then
		table.insert(elements, {label = _U('return_owned_ambulance').." ($"..Config.AmbulancePoundPrice..")", value = 'return_owned_ambulance'})
	end
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_menu', {
		title    = _U('garage'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		menu.close()
		local action = data.current.value
		
		if action == 'list_owned_cars' then
			ListOwnedCarsMenu()
		elseif action == 'list_owned_cars2' then
			ListOwnedCarsMenu("fizzfau")
		elseif action == 'list_owned_boats' then
			ListOwnedBoatsMenu()
		elseif action == 'list_owned_aircrafts' then
			ListOwnedAircraftsMenu()
		elseif action== 'store_owned_cars' then
			StoreOwnedCarsMenu()
		elseif action== 'store_owned_boats' then
			StoreOwnedBoatsMenu()
		elseif action== 'store_owned_aircrafts' then
			StoreOwnedAircraftsMenu()
		elseif action == 'return_owned_cars' then
			ReturnOwnedCarsMenu()
		elseif action == 'return_owned_cars2' then
			ReturnOwnedCarsMenu("fizzfau")
		elseif action == 'return_owned_boats' then
			ReturnOwnedBoatsMenu()
		elseif action == 'return_owned_aircrafts' then
			ReturnOwnedAircraftsMenu()
		elseif action == 'return_owned_policing' then
			ReturnOwnedPolicingMenu()
		elseif action == 'return_owned_ambulance' then
			ReturnOwnedAmbulanceMenu()
		end
		
		--local playerPed = GetPlayerPed(-1)
		--SpawnVehicle(data.current.value)
		
	end, function (data, menu)
		menu.close()
	end)
end

function ListOwnedCarsMenu(fizzfau)
	local elements = {
		{label = _U('spacer3')},
		{label = _U('spacer1')}
	}
	
	ESX.TriggerServerCallback('esx_advancedgarage:getOwnedCars', function(ownedCars)
		if #ownedCars == 0 then
			TriggerEvent("pNotify:SendNotification", {text =_U('garage_nocars'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

		else
			for _,v in pairs(ownedCars) do
				if Config.UseVehicleNamesLua == true then
					local hashVehicule = v.vehicle.model
					local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
					local vehicleName  = GetLabelText(aheadVehName)
					local labelvehicle
					local plate = v.plate
					
					if v.stored then
						labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
					else
						labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
					end
					
					table.insert(elements, {label = labelvehicle, value = v})
				else
					local hashVehicule = v.vehicle.model
					local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
					local labelvehicle
					local plate = v.plate
					
					if v.stored then
						labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
					else
						labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
					end
					
					table.insert(elements, {label = labelvehicle, value = v})
				end
			end
		end
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_car', {
			title    = _U('garage_cars'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value.stored then
				menu.close()
				if fizzfau ~= "fizzfau" then
					SpawnVehicle(data.current.value.vehicle, data.current.value.plate)
				else
					TriggerEvent('fizzfau-vale:spawnVeh', data.current.value.vehicle, data.current.value.plate)
				end
			else
				TriggerEvent("pNotify:SendNotification", {text =_U('car_is_impounded'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function ReturnOwnedCarsMenu(fizzfau)
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedCars', function(ownedCars)
		local elements = {
			--{label = _U('spacer2'), value = 'spacer'}
		}
		
		for _,v in pairs(ownedCars) do
			if Config.UseVehicleNamesLua == true then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local labelvehicle
				local plate = v.plate
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
				local labelvehicle
				local plate = v.plate
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			end
		end
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_car', {
			title    = _U('pound_cars'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyCars', function(hasEnoughMoney)
				if hasEnoughMoney then
					if fizzfau ~= "fizzfau" then
						TriggerServerEvent('esx_advancedgarage:payCar')
						SpawnPoundedVehicle(data.current.value, data.current.value.plate)
					else
						TriggerServerEvent('esx_advancedgarage:payCar')
						TriggerEvent('fizzfau-vale:spawnVeh', data.current.value.vehicle, data.current.value.plate)
					end
				else
					TriggerEvent("pNotify:SendNotification", {text =_U('not_enough_money'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end
