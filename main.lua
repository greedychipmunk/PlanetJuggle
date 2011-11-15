local physics = require "physics" 
local gameUI = require "scripts/gameUI"
local CSL = require "scripts/crawlspaceLib"

CSL.listFeatures()

system.activate( "multitouch" )
physics.start()

local sky = display.newImage( "img/bkg_clouds.png" )
sky.x = 160; sky.y = 240

local ground = display.newImage( "img/ground.png" )
ground.x = 160; ground.y = 545

display.setStatusBar( display.HiddenStatusBar )

physics.addBody( ground, "static", { friction=0.5, bounce=0.3 } )

score = 0
scoreText = display.newText( score, display.viewableContentWidth - 30, 20, native.systemFont, 20 )

scoreText:setTextColor(255, 255, 255)

startView = {}
startText = display.newText("Tap to Start", display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFont, 26)

startText:setTextColor(255, 255, 255)
gameOver = false
crateLayer = display.newGroup()
local function addCrate( event )
	if( not gameOver ) then
		crate = display.newImage( "img/planet80x80.png" )
		crate.x = 180; crate.y = -50; crate.rotation = 5
		
		physics.addBody( crate, { density=3.0, friction=0.5, bounce=0.3 } )
		
		crate:addEventListener( "touch", gameUI.dragBody )
		crateLayer:insert( crate )
		print( "post insert: " .. crateLayer.numChildren )
		scoreText:toFront()
	end
end

local leftWallRect = display.newRect( 0, -50000, 1, 50000 + 480 )
leftWallRect:setFillColor( 255, 255, 255, 100 )
physics.addBody( leftWallRect, "static", { density=1, friction=.5, bounce=0.3 } )

local rightWallRect = display.newRect( display.viewableContentWidth - 1, -50000, 1, 50000 + 480 )
rightWallRect:setFillColor( 255, 255, 255, 100 )
physics.addBody( rightWallRect, "static", { density=1, friction=.5, bounce=0.3 } )

local function ptInside( obj, x, y )
	local inside = false
	local objx = obj.x - ( obj.width / 2 )
	local objy = obj.y - ( obj.height / 2 )
	if ( x >= objx ) and
		( x <= ( objx + obj.width ) ) and
		( y >= objy ) and
		( y <= ( objy + obj.height ) ) then
		inside = true
	end
	return inside
end

local function buttonTouched( e )
	local t = e.target
	if e.phase == "began" then
		t.alpha = .5
		t.active = true
		display.getCurrentStage():setFocus( t )
	elseif e.phase == "moved" and t.active then
		if ptInside( t, e.x, e.y ) then
			t.alpha = .5
		else
			t.alpha = 1
		end
	else
		display.getCurrentStage():setFocus( nil )
	end
	if e.phase == "ended" and t.active then
		t.active = false
		if ptInside( t, e.x, e.y ) then
			t.alpha = 1
			t.action()
		end
	end
end

local function replayAction()
	print( "REPLAY" )
	gameOver = false
	crateLayer.isVisible = true
	addCrate()
	crateTimer = timer.performWithDelay( 10000, addCrate, 99 )
	ground:addEventListener( 'collision', onGroundCollision )
	buttonReplay.isVisible = false
	buttonMenu.isVisible = false
end

local function menuAction()
	print( "MENU" )
	os.exit()
end

buttonReplay = display.newImage( "img/green-button-active100x100.png" )
buttonReplay.x = centerX - 50
buttonReplay.y = centerY - 100
buttonReplay.active = false
buttonReplay.action = replayAction
buttonReplay:addEventListener( "touch", buttonTouched )
buttonReplay.isVisible = false;

buttonMenu = display.newImage( "img/red-button-active100x100.png" )
buttonMenu.x = centerX + 40
buttonMenu.y = centerY + 40
buttonMenu.active = false
buttonMenu.action = menuAction
buttonMenu:addEventListener( "touch", buttonTouched )
buttonMenu.isVisible = false

local function startGame ( event )
	startText.text = ""
	addCrate()
	crateTimer = timer.performWithDelay( 10000, addCrate, 99 )
	sky:removeEventListener( 'tap', startGame )
end

local function cleanGroups ( curGroup, level )
    print( "level: " .. level )
    if curGroup.numChildren then
    	print( "if curGroup.numChildren: " .. curGroup.numChildren )
        while curGroup.numChildren > 0 do
        		print( "while: " .. curGroup.numChildren )
                cleanGroups ( curGroup[curGroup.numChildren], level+1 )
        end
        if level > 0 then
        		print( "level > 0" )
                curGroup:removeSelf()
        end
        else
        		print( "curGroup:removeSelf()" )
        		curGroup:removeSelf()
                curGroup = nil
        return
    end
end

function onGroundCollision( self, event )
	timer.cancel( crateTimer )
	gameOver = true
	buttonReplay.isVisible = true
	buttonMenu.isVisible = true
	cleanGroups( crateLayer, 0 )
	ground:removeEventListener( 'collision', onGroundCollision )
end

sky:addEventListener( 'tap', startGame )
ground:addEventListener( 'collision', onGroundCollision )