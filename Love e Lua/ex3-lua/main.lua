function love.load()
  x = 50 y = 200
  w = 200 h = 150

end

function naimagem (mx, my, x, y)
  return (mx>x) and (mx<x+w) and (my>y) and (my<y+h)
end

function love.keypressed(key)
  local mx, my = love.mouse.getPosition()
  if naimagem (mx,my, x, y) then
	  if key == 'b' then
		 y = 200
	  end
	  if key == 'down' then
		y = y + 10
	  end
	  if key == 'right' then
		 x = x + 10
	  end
  end
end

function love.update (dt)
  local mx, my = love.mouse.getPosition()

end

function love.draw ()
  love.graphics.rectangle("line", x, y, w, h)
end
