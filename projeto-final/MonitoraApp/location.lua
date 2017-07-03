-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------
MQTT = require("mqtt_library")
local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()

function getCoordinates (string)
   coordinates = {}     
   if (string ~= nil) then
     for k, v in string.gmatch(string, "([^=]+)=([^=]+)&") do
       coordinates[k] = v
       print (k, coordinates[k])
     end
   end
   return coordinates
end

lastLocation = "Aguardando localização..."
locationTextParams = { text = lastLocation, 
								x = display.contentCenterX + 5,
								y = 50,
								font = native.systemFont,
								fontSize = 12 }
locationText = display.newText( locationTextParams )
locationText:setFillColor( 0 )	-- black 
myMap = native.newMapView(display.contentCenterX, locationText.y + locationText.contentHeight/2 + 170, 240, 290)

callback = function (topic, message)
	  if topic == "localizacao" then
	  	--atualiza variaveis globais
	  	lastLocation, strCoord = message:match("(.+)$(.+)")
	  	print("LastLocation: "..lastlocation.."  strcCoord: "..strcCoord)
	    local coordinates = getCoordinates(strCoord)
        myMap:setCenter( coordinates[lat], coordinates[lon] )
        myMap:addMarker( coordinates[lat], coordinates[lon] )
	  	locationTextParams.text = lastLocation
	  	locationText = display.newText( locationTextParams )
	  elseif topic == "alerta" then
	  	--mostra pop-up com mensagem de alerta
	  	native.showAlert( "Alerta do usuário", message , { "Ok" } )
	  end
end

native.showAlert( "To aqui", "oiiii" , { "Ok" } )
c = MQTT.client.create("localhost", 1883, callback)
native.showAlert( "Criou client", c , { "Ok" } )
MQTT.Utility.set_debug(true)

c:connect("corona")
c:subscribe({ "alerta", "localizacao" })

function handleMsg()
    c:handler()  
end

timer.performWithDelay(1000, handleMsg, 0)

local function locationHandler( event )
	c:publish("acoes", "LOCALIZAR")
	native.showAlert( "Enviou pra fila de ações", c , { "Ok" } )
end

locationHandler()

function scene:create( event )
	local sceneGroup = self.view
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( 1 )	-- white
	
	local refreshLocationBtn = widget.newButton( 
     { 
        id = "btn_refresh_location", 
        x = display.contentCenterX + 50, 
        y = myMap.y + myMap.contentHeight/2 + 40,
        label = "Atualizar localização",
        onPress = locationHandler
    })

	local function goHome( event )
		composer.gotoScene( "home" )
	end

    local backBtn = widget.newButton( 
     { 
        id = "btn_back", 
        x = display.contentCenterX - 90, 
        y = myMap.y + myMap.contentHeight/2 + 40,
        width = 100,
        label = "<< Voltar",
        onPress = goHome
    })

	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( background )
	sceneGroup:insert( locationText )
	sceneGroup:insert( myMap )
	sceneGroup:insert( refreshLocationBtn )
	sceneGroup:insert( backBtn )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		myMap.isVisible = true
	elseif phase == "did" then
		-- Called when the scene is now on screen
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		myMap.isVisible = false
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view	
	-- Called prior to the removal of scene's "view" (sceneGroup)

end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene