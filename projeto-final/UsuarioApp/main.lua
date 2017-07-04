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

local initTextParams = { text = "Bem vindo(a) \nao seu assistente pessoal.", 
								x = display.contentCenterX,
								y = display.contentCenterY,
								font = native.systemFont,
								fontSize = 23,
								align = center }
local initText = display.newText( initTextParams )
initText:setFillColor( 1 )

local function locationHandler( event )
    if ( event.isError ) then
        print( "Map Error: " .. event.errorMessage )
        native.showAlert( "DEBUG", tostring(event.errorMessage) , { "OK" } )
    else
    	-- rua, numero, bairro, cidade e país
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
	local fullLocationAndTime = nil
	local data, hora = getCurrentDateAndTime()
	local lat, lon = getLocation() 

	if lat ~= nil and lon ~= nil then
		myMap:nearestAddress( lat, lon, locationHandler )
	end
	
	local dateAndTime = "As "..hora.." de "..data.."."
	fullLocationAndTime = (messageLocation or " ")..dateAndTime
	
	return fullLocationAndTime, lat, lon
end


eventsAndLocation = function (topic, msg)
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
	  		local message = "Aguardando"
		  	local stringLocation, lat, lon = getFullLocationAndTime()  
		  	
		  	if lat ~= nil and lon ~= nil then
		  		local location = "lat="..lat.."&".."lon="..lon.."&"
		  		message = stringLocation.."$"..location
		  	end

		  	c:publish("localizacao", message) 
		end
	  end
end

c = MQTT.client.create("192.168.15.80", 1883, eventsAndLocation)

c:connect("corona")
c:subscribe({"eventos", "acoes"})


function handleMsg()
    c:handler() 
end

timer.performWithDelay(1000, handleMsg, 0)

introSound = audio.loadSound( "intro.wav" )
audio.play( introSound )

--timer.performWithDelay(2000, getFullLocationAndTime)