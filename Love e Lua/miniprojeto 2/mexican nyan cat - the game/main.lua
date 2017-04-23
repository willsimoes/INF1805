local frame_width, frame_height = love.graphics.getDimensions( )

function newcat ()
  local x, width, height = 100, 100, 50
  local y = frame_height-(height+3)

  return {
  ground = y,
  y_velocity = 0,
  jump_height = -300,
  gravity = -500,
  draw = function () 
    love.graphics.rectangle("line", x, y, width, height)
  end,
  update = function (dt)
  	if cat.y_velocity ~= 0 then
  		y = y + cat.y_velocity * dt          
		cat.y_velocity = cat.y_velocity - cat.gravity * dt 
	end
	    
    if y > cat.ground then    
		cat.y_velocity = 0       
    	y = cat.ground    
	end

	if y < 0 then
		y = 3
	end
  end
}
end

function newtaco() 
	local x, width, height = frame_width, 50, 50
	local y = frame_height/2
	return {
	draw = function()
		love.graphics.rectangle("line", x, y, width, height)
	end,
	update = function (dt)
		x = x - 3
		if (x < 0) then
	 		taco = nil
	 	end
	end
}
end

function newcucumber() 
	local x, width, height = frame_width, 10, 40
	local y = frame_height-(height+3)
	return {
	draw = function()
		love.graphics.rectangle("line", x, y, width, height)
	end,
	update = function (dt)
	 	x = x - 3 
	 	if (x < 0) then
	 		cucumber = nil
	 	end
	end
}
end

-- cria tudo o que os "objetos" vai precisar
function love.load()
  cat = newcat() 
  taco = newtaco() 
  cucumber = newcucumber() 
end

-- desenha todos eles a cada frame
-- chama todas as funções draw de cada "objeto"
function love.draw()
  --[[ "grama":
  local y = frame_height-30
  love.graphics.line(0, y, frame_width, y)
  --]]
  cat.draw()
  if taco then 
  	 taco.draw()
  end
  if cucumber then 
  	cucumber.draw()
  end


end

-- chamado em cada frame para atualizar o jogo
function love.update(dt)
  if love.keyboard.isDown('right') then
  	if taco then
  		taco:update(dt)
  	end
  	if cucumber then
  		cucumber:update(dt)
  	end
  elseif love.keyboard.isDown('space') then
	    cat.y_velocity = cat.jump_height
  end


  cat.update(dt)
  
 
end
