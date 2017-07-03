-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------
MQTT = require("mqtt_library")
MQTT.Utility.set_debug(true)
local widget = require( "widget" )

---------------------------------------------------------- Parte Gráfica

local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
background:setFillColor( 1 )	-- white

local locationTextParams = { text = "Aguardando localização...", 
								x = display.contentCenterX + 5,
								y = 50,
								font = native.systemFont,
								fontSize = 12 }
local locationText = display.newText( locationTextParams )
locationText:setFillColor( 0 )	-- black 

myMap = native.newMapView(display.contentCenterX, locationText.y + locationText.contentHeight/2 + 170, 240, 290)

function getCoordinates (string)
   local coordinates = {}     
   if (string ~= nil) then
     for k, v in string.gmatch(string, "([^=]+)=([^=]+)&") do
       coordinates[k] = v
       print (k, coordinates[k])
     end
   end
   return coordinates
end

---------------------------------------------------------- Conexão com MQTT Broker
callback = function (topic, message)
	  native.showAlert( "DEBUG", "Topico:  "..tostring(topic).."\nMensagem: "..tostring(message), { "Ok" } )
	  if topic == "localizacao" then
	  	--atualiza variaveis globais
	  	lastLocation, strCoord = message:match("([^$]+)%$(.+)")
	  	native.showAlert( "Alerta do usuário", tostring(lastLocation)..tostring(strcCoord) , { "Ok" } )
	  	--print("LastLocation: "..lastlocation.."  strcCoord: "..strcCoord)
	  	if strcCoord ~= nil then
	  		native.showAlert( "Alerta do usuário", tostring(strcCoord) , { "Ok" } )
	    	local coordinates = getCoordinates(strCoord)
       		myMap:setCenter( coordinates[lat], coordinates[lon] )
        	myMap:addMarker( coordinates[lat], coordinates[lon] )
        end
        if strcCoord ~= nil then 
        	native.showAlert( "Alerta do usuário", tostring(strcCoord) , { "Ok" } )
        	locationTextParams.text = lastLocation
	  		locationText = display.newText( locationTextParams )
        end
	  	
	  elseif topic == "alerta" then
	  	--mostra pop-up com mensagem de alerta
	  	native.showAlert( "Alerta do usuário", tostring(message) , { "Ok" } )
	  end
end

c = MQTT.client.create("192.168.15.80", 1883, callback)
c:connect("corona")

local ret = c:subscribe({ "alerta", "localizacao" })

function handleMsg()
    c:handler()
end

timer.performWithDelay(1000, handleMsg, 0)

local function locationHandler( event )
	c:publish("acoes", "LOCALIZAR")
end

locationHandler()


---------------------------------------------------------- Parte grafica 2

local refreshLocationBtn = widget.newButton( 
 { 
    id = "btn_refresh_location", 
    x = display.contentCenterX + 50, 
    y = myMap.y + myMap.contentHeight/2 + 40,
    label = "Atualizar localização ",
    onPress = locationHandler
})






