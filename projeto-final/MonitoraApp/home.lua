-----------------------------------------------------------------------------------------
--
-- home.lua
--
-----------------------------------------------------------------------------------------

local widget = require "widget"
local composer = require( "composer" )
local scene = composer.newScene()
widget.setTheme( "widget_theme_android_holo_light" )

function scene:create( event )
    local sceneGroup = self.view
    -- Called when the scene's view does not exist.
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
    
    -- create a white background to fill screen
    local background = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
    background:setFillColor( 1 )    -- white

    -- event listeners for location view:
    local function locationView( event )  
        composer.gotoScene( "location" )
    end

    local function makeACall ( event )
        system.openURL( "tel:988526176" )
    end

    local reqLocationBtn = widget.newButton( 
     { 
        id = "btn_req_location", 
        x = display.contentCenterX , 
        y = display.contentCenterY,
        label = "Localizar",
        onPress = locationView
    })

    local callBtn = widget.newButton( 
     { 
        id = "btn_call", 
        x = display.contentCenterX , 
        y = reqLocationBtn.y + 50,
        label = "Ligar para usuário",
        onPress = makeACall
    })
    
    -- all objects must be added to group (e.g. self.view)
    sceneGroup:insert( background )
    sceneGroup:insert( reqLocationBtn )
    sceneGroup:insert( callBtn )
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






 
