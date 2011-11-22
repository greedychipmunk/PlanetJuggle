local physics = require "physics" 
local gameUI = require "gameUI"
local CSL = require "crawlspaceLib"

CSL.listFeatures()

system.activate( "multitouch" )
physics.start()

local sky = display.newImage( "img/space-bg1320x1320.png" )
--sky.x = 300
--sky.y = 300


display.setStatusBar( display.HiddenStatusBar )

score = 0
scoreText = display.newText( score, display.viewableContentWidth - 30, 20, native.systemFont, 20 )

scoreText:setTextColor(255, 255, 255)

startView = {}
startText = display.newText( "Tap to Start", display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFont, 26 )

startText:setTextColor(255, 255, 255)
gameOver = false
planetLayer = display.newGroup()
local function addPlanet( event )
	if( not gameOver ) then
		planet = display.newImage( "img/planet80x80.png" )
		planet.x = 180; planet.y = -50; planet.rotation = 5
		
		physics.addBody( planet, { density=3.0, friction=0.5, bounce=0.3 } )
		
		planet:addEventListener( "touch", gameUI.dragBody )
		planetLayer:insert( planet )
		scoreText:toFront()
	end
end

local leftWallRect = display.newRect( 0, -50000, 1, 60000 )
leftWallRect:setFillColor( 0, 0, 0, 100 )
physics.addBody( leftWallRect, "static", { density=1, friction=.5, bounce=0.3 } )

local rightWallRect = display.newRect( display.viewableContentWidth, -50000, 1, 60000 )
rightWallRect:setFillColor( 0, 0, 0, 100 )
physics.addBody( rightWallRect, "static", { density=1, friction=.5, bounce=0.3 } )

local groundRect = display.newRect( 0, display.viewableContentHeight, display.stageWidth, 1 )
groundRect:setFillColor( 0, 0, 0, 100 )
physics.addBody( groundRect, "static", { density = 1, friction = .5 } )

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
	gameUI.score = 0
	scoreText.text = 0
	gameOver = false
	planetLayer.isVisible = true
	addPlanet()
	planetTimer = timer.performWithDelay( 10000, addPlanet, 99 )
	groundRect:addEventListener( 'collision', onGroundCollision )
	buttonReplay.isVisible = false
	buttonMenu.isVisible = false
end

local function menuAction()
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
	addPlanet()
	planetTimer = timer.performWithDelay( 10000, addPlanet, 99 )
	sky:removeEventListener( 'tap', startGame )
end

local function cleanGroups ( curGroup, level )
    if curGroup.numChildren then
        while curGroup.numChildren > 0 do
                cleanGroups ( curGroup[curGroup.numChildren], level+1 )
        end
        if level > 0 then
                curGroup:removeSelf()
        end
        else
        		curGroup:removeSelf()
                curGroup = nil
        return
    end
end

function onGroundCollision( self, event )
	timer.cancel( planetTimer )
	gameOver = true
	buttonReplay.isVisible = true
	buttonMenu.isVisible = true
	cleanGroups( planetLayer, 0 )
	groundRect:removeEventListener( 'collision', onGroundCollision )
end

sky:addEventListener( 'tap', startGame )
groundRect:addEventListener( 'collision', onGroundCollision )