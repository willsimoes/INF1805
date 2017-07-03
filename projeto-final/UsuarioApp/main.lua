-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

MQTT = require("mqtt_library")

local myMap = native.newMapView( 20, 20, 280, 360 )
myMap.isVisible = false
myMap:setCenter( 37.331692, -122.030456 )

local messageLocation = nil

local function locationHandler( event )
    if ( event.isError ) then
        print( "Map Error: " .. event.errorMessage )
        native.showAlert( "DEBUG", tostring(event.errorMessage) , { "OK" } )
    else
    	--rua, numero, bairro, cidade e paíss
    	messageLocation = "Localizado em:\n" ..
    	event.street..", "..event.streetDetail..".\n" ..
    	event.cityDetail..", "..event.city..", "..event.country..".\n"
    end
end

local attempts = 0

function getLocation( event ) 
	
	local currentLocation = myMap:getUserLocation()

	if ( currentLocation.errorCode or ( currentLocation.latitude == 0 and currentLocation.longitude == 0 ) ) then
	        attempts = attempts + 1
	 
	        if ( attempts > 10 ) then
	            native.showAlert( "Sem sinal de GPS", "Não consigo sicronizar com o GPS", { "Ok" } )
	        else
	            timer.performWithDelay( 1000, getLocation )
	        end
	else
		return currentLocation.latitude, currentLocation.longitude
	end
end


function getCurrentDateAndTime()
	return os.date( "%x" ), os.date(" %X ")
end

function getFullLocationAndTime()
	lat, lon = getLocation() 
	if lat == nil or lon == nil then
		native.showAlert( "DEBUG", "lat/lon nil" , { "Uhul" } )
	else
		myMap:nearestAddress( lat, lon, locationHandler )
	end
	local hora, data = getCurrentDateAndTime()
	local dateAndTime = "Às "..hora.." de "..data.."."
	return (messageLocation or " ")..dateAndTime
end

eventsAndLocation = function (topic, msg)
	  native.showAlert( "DEBUG", "Chegou nova msg", { "Ok" } )
	  if topic == "eventos" then
	  	if msg == "ajuda" then
	  		local message = "Alerta de ajuda!!\n"..getFullLocationAndTime()
	  		c:publish("alerta", message)

	  		local options = { 
	  					to = { "988267269" }, 
	  					body = message 
	  				}
			native.showPopup( "sms", options )
	  	elseif msg == "queda" then
	  		local message = "Alerta de queda do usuário!!\n"..getFullLocationAndTime()
	  		c:publish("alerta", message) 

	  		local options = { 
	  					to = { "988267269" }, 
	  					body = message 
	  				}
			native.showPopup( "sms", options )
	  	end
	  elseif topic == "acoes" then
	  	if msg == "LOCALIZAR" then
		  	local stringLocation = getFullLocationAndTime() 
		  	lat, lon = getLocation()
		  	local location = "lat="..lat.."&".."lon="..lon.."&"
		  	local message = stringLocation.."$"..location
		  	c:publish("localizacao", message) 
		end
	  end
end

c = MQTT.client.create("192.168.15.80", 1883, eventsAndLocation)

c:connect("corona")
--[[if string == nil then
	native.showAlert( "parece que se conectou", tostring(c) , { "Ok" } )
end
if string ~= nil then
	native.showAlert( "olarr 2 com Broker", tostring(c)..string , { "Ok" } )
end]]--

ret = c:subscribe({"eventos", "acoes"})
--[[native.showAlert( "oieeee 2", "to aqui" , { "Ok" } )
if ret ~= nil then
	native.showAlert( "opa", tostring(ret) , { "Ok" } )
else 
	native.showAlert( "opa", "nulo baby" , { "Ok" } )
end]]--

function handleMsg()
    c:handler() 
    --[[if ret2 ~= nil then
		native.showAlert( "opa", tostring(ret2) , { "Ok" } )
	else 
		native.showAlert( "opa", "nulo baby" , { "Ok" } )
	end]]-- 
end

timer.performWithDelay(1000, handleMsg, 0)
