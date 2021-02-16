-- Copyright (c) 2017 Corona Labs Inc.
-- Code is MIT licensed and can be re-used; see https://www.coronalabs.com/links/code/license
-- Other assets are licensed by their creators:
--    Art assets by Kenney: http://kenney.nl/assets
--    Music and sound effect assets by Eric Matyas: http://www.soundimage.org

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Seed the random number generator
math.randomseed( os.time() )

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

-- Initialize variables
local lives = 3
local score = 0
local died = false

local asteroidsTable = {}
local treesTable = {}
local starsTable = {}

local ship
local plane
local prevX = display.screenOriginX
-- local prevY = display.screenOriginY + 50
local yBottom = display.contentHeight
local prevY = math.random( display.screenOriginY, yBottom )
print("display.screenOriginY : " .. display.screenOriginY)
print("yBottom : " .. yBottom)
print("prevY : " .. prevY)

local starPrevX = display.screenOriginX
local starYBottom = display.contentHeight

local gameLoopTimer
local livesText
local scoreText

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

-- Load the background
local background = display.newImageRect( backGroup, "background.png", 800 * 3, 1400 )
background.x = display.contentCenterX
background.y = display.contentCenterY

print("background.x : " .. background.x)
print("background.y : " .. background.y)

print("display.contentWidth : " .. display.contentWidth)
print("display.contentHeight : " .. display.contentHeight)

print("display.contentScaleX : " .. display.contentScaleX)

print("screenOriginX : " .. display.screenOriginX)
print("screenOriginY : " .. display.screenOriginY)

ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
ship.x = display.contentCenterX
ship.y = display.contentHeight - 100
physics.addBody( ship, { radius=30, isSensor=true } )
ship.myName = "ship"

-- Load the plane
plane = display.newImageRect( mainGroup, "Fly (1).png", 120, 120 )
plane.x = display.contentCenterX
plane.y = display.contentCenterY
plane.velocity = 0
plane.gravity = 0.6

physics.addBody( plane, { radius = 30} )
plane.myName = "plane"

-- Display lives and score
livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

local backgroundScroll = 0
local groundScroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 800

local dt = 10


local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end

local function createTree()
    local newTree = display.newImageRect( mainGroup,"Tree_2.png", 102, 85)
    table.insert(treesTable, newTree)
    physics.addBody( newTree, "static", { radius = 40, bounce = 0.8});
    newTree.myName = "tree"

	newTree.x = prevX + 200
    newTree.y = math.random( display.screenOriginY, yBottom )
    prevX = newTree.x
	-- prevY = math.random( display.screenOriginY, display.screenOriginY + 400)
	-- prevY = math.random( display.screenOriginY, yBottom )
end

local function createStar()
	local newStar = display.newImageRect( mainGroup,"star.png",100, 100);
	table.insert( starsTable, newStar )
	physics.addBody( newStar,"static", { radius = 40 });
	newStar.myName = "star"

	newStar.x = starPrevX + 200
	newStar.y = math.random( display.screenOriginY, starYBottom )
	starPrevX = newStar.x
end

local function movePlan( event )
    local plane = event.target
    local phase = event.phase

    if ( "began" == phase) then
        display.currentStage:setFocus( plane )
        plane.touchOffsetX = event.x - plane.x
    
    elseif ( "moved" == phase ) then
        plane.x = event.x - plane.touchOffsetX
    
    elseif ( "ended" == phase or "cancelled" == phase) then
        display.currentStage:setFocus( nil)
    end
       
    return true
end

local function tapListener( event )
 
    -- Code executed when the button is tapped
    print( "Object tapped: " .. tostring(event.target) )  -- "event.target" is the tapped object
    -- local plane = event.target

    -- plane.y = event.y - 20
	-- plane.y = event.y + 10

	plane.velocity = 10
	
    return true
end


-- plane:addEventListener("touch", movePlan)
-- plane:addEventListener( "tap", tapListener )  -- Add a "tap" listener to the object



local function update()
	if (died == false) then
		plane.velocity = plane.velocity - plane.gravity
		plane.y = plane.y - plane.velocity
		-- plane.x = plane.x + 2
		-- background.x = background.x - 10

		-- local background_temp = display.newImageRect( backGroup, "background.png", 800, 1400 )
		-- -- background.x = display.contentCenterX
		-- -- background.y = display.contentCenterY
		-- background = background + "" + background_temp


		-- if (background.x <  800) then
		-- 	background.x = 800
		-- 	background.y = display.contentCenterY
		-- end

		-- timer.performWithDelay(1000, update)

		background.x = background.x - 3

		for i = #treesTable, 1, -1 do
			treesTable[i].x = treesTable[i].x - 3
			if (treesTable[i].x < display.screenOriginX) then
				display.remove( treesTable[i])
				table.remove( treesTable, i)
			end
		end

		for i = #starsTable, 1, -1 do
			if (starsTable[i] ~= nil and starsTable[i].x ~= nil) then
				print("starsTable[i] ~= nil ")
				print("starsTable[i].x : " .. starsTable[i].x)
				starsTable[i].x = starsTable[i].x - 3
				if (starsTable[i].x < display.screenOriginX ) then 
					display.remove( starsTable[i] )
					table.remove( starsTable, i )
				end
			end
		end
		

		-- backgroundScroll = ( backgroundScroll + BACKGROUND_SCROLL_SPEED * dt ) % BACKGROUND_LOOPING_POINT
		-- groundScroll = ( groundScroll + GROUND_SCROLL_SPEED * dt ) % display.contentWidth -- FOR NOW I USE display.contentWidth insted of VIRTUAL_WIDTH

		-- if ( backgroundScroll ~= 0)
		-- then
		-- 	background.x = display.contentCenterX
		-- 	background.y = display.contentCenterY
		-- end

		if ( background.x < - 200)
		then 
			-- Load the background
			background.x = 800
			
		end
	end
end

Runtime:addEventListener("enterFrame", update)
Runtime:addEventListener("tap", tapListener)

local function gameLoop()
	createTree()
	createStar()
	

	-- Remove asteroids which have drifted off screen
	for i = #asteroidsTable, 1, -1 do
		local thisAsteroid = asteroidsTable[i]

		if ( thisAsteroid.x < -100 or
			 thisAsteroid.x > display.contentWidth + 100 or
			 thisAsteroid.y < -100 or
			 thisAsteroid.y > display.contentHeight + 100 )
		then
			display.remove( thisAsteroid )
			table.remove( asteroidsTable, i )
		end
	end
end

gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )


local function restorePlan()

	plane.isBodyActive = false
	-- plane.x = display.contentCenterX
	-- plane.y = display.contentHeight - 100

	plane.x = display.contentCenterX
	plane.y = display.contentCenterY
	-- plane.velocity = 0
	-- plane.gravity = 0.6

	-- physics.addBody( plane, { radius = 30} )
	-- plane.myName = "plane"

	-- Fade in the ship
	transition.to( plane, { alpha=1, time=4000,
		onComplete = function()
			plane.isBodyActive = true
			died = false
		end
	} )
end

local function onCollision( event )
	if (event.phase == "began") then
		local obj1 = event.object1
		local obj2 = event.object2

		if ( (obj1.myName == "plane" and obj2.myName == "tree" ) or
			( obj1.myName == "tree" and obj2.myName == "plane" ) )
		then
			-- display.remove( obj1)
			-- display.remove( obj2 )

			-- for i = #treesTable, 1, -1 do
			-- 	if (treesTable[i] == obj1 or treesTable[i] == obj2 ) then
			-- 		table.remove( treesTable, i);
			-- 		break
			-- 	end
			-- end

			if (died == false) then
				died = true
				display.remove( plane )
				timer.performWithDelay( 1000, restorePlan )
			end

		end
	end
		
end

local function collectStar( event ) 
	print("[collectStar( event )] Inside")
	if ( event.phase == "began") then
		local obj1 = event.object1
		local obj2 = event.object2

		if ( (obj1.myName == "plane" and obj2.myName == "star") ) then
			display.remove( obj2 )
			-- table.remove(starsTable, obj2)
			
		elseif ( (obj1.myName == "star" and obj2.myName == "plane") ) then
			display.remove(obj1)
			-- table.remove(starsTable, obj1);

		end

		score = score + 10
		scoreText.text = "Score: " .. score

	end
end

Runtime:addEventListener( "collision", onCollision )
Runtime:addEventListener("collision", collectStar)