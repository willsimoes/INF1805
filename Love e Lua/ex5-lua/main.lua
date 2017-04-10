function love.load()
  ret1 = retangulo (50, 200, 300, 150);
  ret2 = retangulo (300, 30, 300, 150);
end

function retangulo (x,y,w,h)
	originalx, originaly, rx, ry, rw, rh = x,y,x,y,w,h;
	return {
		draw = function ()
			love.graphics.rectangle("line", rx, ry, rw, rh)
		end,
		keypressed = function (key) 
			local mx,my = love.mouse.getPosition()
			if naimagem (mx,my, rx, ry) then
			  if key == 'b' then
				 ry = originaly
			  end
			  if key == 'down' then
				 ry = ry + 10
			  end
			  if key == 'right' then
				 rx = rx + 10
			  end
			end
		end,
		update = function () 
			local mx, my = love.mouse.getPosition()
		end
	}
end

function naimagem (mx, my, x, y)
  return (mx>x) and (mx<x+rw) and (my>y) and (my<y+rh)
end

function love.keypressed(key)
  ret1.keypressed(key);
  ret2.keypressed(key);
end

function love.update (dt)
  ret1.update();
  ret2.update();
end

