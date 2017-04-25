local frame_width, frame_height = love.graphics.getDimensions( )
local elements = {}
local active_elements = {}



function newcat ()
  local x, width, height = 100, 100, 50
  local y = frame_height-(height+3)

  return {
  score = 0,
  ground = y,
  y_velocity = 0,
  jump_height = -300,
  gravity = -500,
  pos = function () 
  	return x, x+width, y, y+height
  end,
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
  end,
  affected = function (posx, posy) 
  	if posx>x and posx<x+width and posy>y and posy<y+height then
  		return true
  	else
  		return false
  	end
  end
}
end

function newtaco(y) 
	local x, width, height = frame_width, 50, 40
	--local y = frame_height/2
	return {
	points = 20,
	draw = function()
		love.graphics.rectangle("line", x, y, width, height)
	end,
	update = function (dt, index)
		x = x - 3
		if (x < 0) then
			print("remove elemento de index igual a", index)
	 		table.remove(active_elements, index)
	 		print("depois da remocao - qtd de elementos ativos",#active_elements)
	 	end
 	end,
 	pos = function ()
 		return x+(width/2), y+(height/2)
 	end
}
end

function newcucumber(y) 
	local x, width, height = frame_width, 10, 40
	--local y = frame_height-(height+3)
	return {
	points = -50,
	draw = function()
		love.graphics.rectangle("line", x, y, width, height)
	end,
	update = function (dt, index)
	 	x = x - 3 
	 	if (x < 0) then
	 		print("remove elemento de index igual a", index)
	 		table.remove(active_elements, index)
	 		print("depois da remocao - qtd de elementos ativos",#active_elements)
	 	end
	end,
	pos = function ()
 		return x+(width/2), y+(height/2)
 	end

}
end


function love.load()
  math.randomseed(os.time())
  cat = newcat() 
  --[[taco = newtaco() 
  cucumber = newcucumber() ]]--
  create_elements()

  pick_active_elements = coroutine.wrap ( function ()
  							while true do
  								print("entrei na pick_active_elements")
  								local index = math.random(#elements)
  								local e = elements[index]
  								table.remove(elements, index)
  								table.insert(active_elements, e)
  								coroutine.yield()
							end
						end)

end

function create_elements()
	for i = 1,10 do
		elements[i] = newcucumber(math.random(5, frame_height-40+3))
	end
	for i = 11, 25 do
		elements[i] = newtaco(math.random(5, frame_height-40+3))
	end
	print("criei elementos", #elements)
end

function love.draw()
  cat.draw()
 --[[if taco then 
  	 taco.draw()
  end
  if cucumber then 
  	cucumber.draw()
  end]]--

  for i, element in ipairs(active_elements) do
  	if element then 
  		element.draw()
  	end
  end
end

function is_empty(list)
	if next(list) == nil then
   		return true
	end
	return false
end


function love.update(dt)
	--print(cat.score)
	if love.keyboard.isDown('right') then
		--[[if taco then
			taco:update(dt)
		end
		if cucumber then
			cucumber:update(dt)
		end]]--

		if is_empty(active_elements) then
			print("lista de elementos ativos eh vazia")
			if is_empty(elements) then
				print("lista de elementos existentes eh vazia")
				create_elements()
			else
				print("lista de elementos existentes n eh vazia - escolhe novos para ativos")
				print("numero de elementos existentes", #elements)
				num = math.random(#elements/4)
				print("quantidade de escolhidos", num)
				for i = 1, num do
					print("chamei a pick active", i)
					pick_active_elements()
				end
			end
		else 
			print("lista de ativos nao eh vazia", #active_elements)
			for i in ipairs(active_elements) do
				if active_elements[i] then 
					active_elements[i].update(dt, i)
				end
			end
		end
		
	elseif love.keyboard.isDown('space') then
		cat.y_velocity = cat.jump_height
	end

	cat.update(dt)

	for i, element in ipairs(active_elements) do
		if element then 
			local posx, posy = element.pos()
			if cat.affected(posx, posy) then
				cat.score = cat.score + element.points
				table.remove(active_elements, i)
			end
		end
	end

	--[[if cucumber then
		local posx, posy = cucumber.pos()
		if cat.affected(posx, posy) then
			cat.score = cat.score - 50
			cucumber = nil
		end 
	end

	if taco then
		posx, posy = taco.pos()
		if cat.affected(posx, posy) then
			cat.score = cat.score + 20
			taco = nil
		end
	end]]--
end
