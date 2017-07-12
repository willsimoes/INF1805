-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
MQTT = require("mqtt_library")
MQTT.Utility.set_debug(true)
local widget = require( "widget" )

---------------------------------------------------------- Parte Gráfica

local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
background:setFillColor( 1 ) -- fundo branco

local locationTextParams = { text = "Aguardando localização...", 
								x = display.contentCenterX + 5,
								y = 50,
								font = native.systemFont,
								fontSize = 12 }
local locationText = display.newText( locationTextParams )
locationText:setFillColor( 0 )	-- cor da fonte: preta 

myMap = native.newMapView(display.contentCenterX, locationText.y + locationText.contentHeight/2 + 170, 240, 290)

function getCoordinates (coordStr)
   local coordinates = {}   
   if (coordStr ~= nil) then
     for k, v in string.gmatch(coordStr, "(%a+)=([-]?[%d]+%.[%d]+)&") do
       coordinates[k] = v
     end
   end
   return coordinates
end

---------------------------------------------------------- Conexão com MQTT Broker
callback = function (topic, message)
	  if topic == "localizacao" then
	  	if message == "Aguardando" then
	  		return 
	  	end
	  	--atualiza variaveis globais
	  	lastLocation, strCoord = message:match("([^$]+)%$(.+)")
	  	if strCoord ~= nil then
	    	local coord = getCoordinates(strCoord)
	    	if coord["lat"] ~= nil and coord["lon"] ~= nil then
	    		local latitude = tonumber(coord["lat"])
	    		local longitude = tonumber(coord["lon"])
       			myMap:setCenter( latitude, longitude ) 
             	myMap:addMarker( latitude, longitude )
	    	end
	    	
        end
        if lastLocation ~= nil then 
        	locationText.text = lastLocation
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


local function pedeLocalizacao ()
	c:publish("acoes", "LOCALIZAR")
end

local function locationHandler( event )
	timer.performWithDelay(1000, pedeLocalizacao, 2)
end


---------------------------------------------------------- Parte grafica 2

local refreshLocationBtn = widget.newButton( 
 { 
    id = "btn_refresh_location", 
    x = display.contentCenterX + 50, 
    y = myMap.y + myMap.contentHeight/2 + 40,
    label = "Atualizar localização ",
    onPress = locationHandler
})






