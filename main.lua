local rings = {}
local newRing

local mouseX, mouseY = 0, 0
local score = 0
local step = 0

local scroll1, scroll2

function love.load()
	scroll1 = 0
	scroll2 = love.graphics.getWidth()
	math.randomseed(os.time())
	newRing = { hue = math.random(255) }
end

function love.update()
	mouseX, mouseY = love.mouse.getPosition()
	scroll1 = scroll1 - 1
	scroll2 = scroll2 - 1
	if scroll1 < -love.graphics.getWidth() then scroll1 = love.graphics.getWidth() end
	if scroll2 < -love.graphics.getWidth() then scroll2 = love.graphics.getWidth() end
end	

function love.mousepressed()
	if step == 0 then
		newRing.major = mouseY
		step = 1
	elseif step == 1 then
		newRing.minor = math.abs(mouseY - newRing.major)
		rings[#rings+1] = newRing
		newRing = { hue = math.random(255) }
		step = 0
		score = updateScore()
	end
end

-- this is all bullshit
function updateScore()
	local score = 0
	local pixels = {}
	for i = 0, love.graphics.getHeight() do
		pixels[i] = -1
	end
	setmetatable(pixels, { __newindex = function() return -1 end })
	for _, ring in ipairs(rings) do
		for i=ring.major - ring.minor, ring.major + ring.minor do
			pixels[i] = ring.hue
		end
	end
	for i = 0, love.graphics.getHeight() do
		if pixels[i] ~= -1 then
			local bestHue = i * 255 / love.graphics.getHeight()
			score = score + 255 - math.abs(bestHue - pixels[i])
		end
	end
	score = 100 * math.pow(score / love.graphics.getHeight() / 255, 2)
	return score
end

function love.draw()
	for _, ring in ipairs(rings) do
		drawRing(ring)
	end
	drawRing(newRing)
	drawText(tostring(score), 24, 24)
	drawText("AbigailBuccaneer 0hgamejam.eu", scroll1, love.graphics.getHeight() - 24)
	drawText("AbigailBuccaneer 0hgamejam.eu", scroll2, love.graphics.getHeight() - 24)
end

function drawText(string, x, y)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(string, x + 2, y + 2)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(string, x, y)
end

function drawRing(ring)
	local major = ring.major or mouseY
	local minor = ring.minor or (ring.major and math.abs(major - mouseY) or 16)
	local hue = ring.hue
	love.graphics.setColor(HSL(hue, 255, 128, 255))
	love.graphics.setLineWidth(minor * 2)
	love.graphics.circle("line", love.graphics.getWidth() / 2, love.graphics.getHeight(), love.graphics.getHeight() - major, 64)
end
	

function HSL(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255,a
end
