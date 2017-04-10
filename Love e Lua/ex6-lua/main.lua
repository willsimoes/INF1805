function love.load()
  local x, y, r, w = 20, 100, 50, 100;
  vetor_ret = {}    
   for i=1, 5 do
	  local ret = retangulo (x, y, r, w);
	  vetor_ret[i] = ret;
	  x = x + 800;
	  y = y + 100;
	  r = r + 50;
	  w = w + 50;
    end	
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
   for i=1, 5 do
	vetor_ret[i].keypressed(key)
   end
end

function love.update (dt)
  for i=1, 5 do
	vetor_ret[i].update()
   end
end

