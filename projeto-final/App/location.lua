-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

function scene:create( event )
	local sceneGroup = self.view
	
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	
	-- create a white background to fill screen
	local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor( 1 )	-- white
	
	-- create some text
	local locationString = "Última localização: \nShopping da Gávea, R. Marquês de São Vicente, 52\n Gávea, Rio de Janeiro - RJ\n Às 19:22 de 26/06/2017"
	local locationTextParams = { text = locationString, 
								x = display.contentCenterX + 5,
								y = 50,
								font = native.systemFont,
								fontSize = 11 }

	local locationText = display.newText( locationTextParams )
	locationText:setFillColor( 0 )	-- black

	local myMap = native.newMapView( 20, 20, 100, 180 )
	myMap.x = display.contentCenterX
	 
	local attempts = 0
	 
	local locationText = display.newText( "Location: ", 0, 400, native.systemFont, 16 )
	locationText.anchorY = 0
	locationText.x = display.contentCenterX
	 
	local function locationHandler( event )
	 
	    local currentLocation = myMap:getUserLocation()
	 
	    if ( currentLocation.errorCode or ( currentLocation.latitude == 0 and currentLocation.longitude == 0 ) ) then
	        locationText.text = currentLocation.errorMessage
	 
	        attempts = attempts + 1
	 
	        if ( attempts > 10 ) then
	            native.showAlert( "No GPS Signal", "Can't sync with GPS.", { "Okay" } )
	        else
	            timer.performWithDelay( 1000, locationHandler )
	        end
	    else
	        locationText.text = "Current location: " .. currentLocation.latitude .. "," .. currentLocation.longitude
	        myMap:setCenter( currentLocation.latitude, currentLocation.longitude )
	        myMap:addMarker( currentLocation.latitude, currentLocation.longitude )
	    end
	end

	locationHandler()
	
	-- all objects must be added to group (e.g. self.view)
	sceneGroup:insert( background )
	sceneGroup:insert( locationText )
	sceneGroup:insert( myMap )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.

	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene