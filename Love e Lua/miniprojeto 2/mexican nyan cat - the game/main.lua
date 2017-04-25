local frame_width, frame_height = love.graphics.getDimensions( )
local elements = {}
local active_elements = {}
local curr_time = 0;


function newcat ()
  local x, width, height = 100, cat_img:getWidth(), cat_img:getHeight()
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
    love.graphics.draw(cat_img, x, y)
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

function newtaco(y, temp) 
	local x, width, height = frame_width, taco_img:getWidth(), taco_img:getHeight()
	return {
	wait_element = nil,
	points = 20,
	draw = function()
		love.graphics.draw(taco_img, x, y)
	end,
	update = coroutine.wrap(function (self, dt, index)
		while true do
			x = x - 4
			if (x < 0) then
				print("remove elemento de index igual a", index)
				print(debug_percorre(active_elements))
		 		table.remove(active_elements, index)
		 		print("depois da remocao - qtd de elementos ativos",#active_elements)
		 	end
		 	wait(temp/1000, self)
		 end
 	end),
 	pos = function ()
 		return x+(width/2), y+(height/2)
 	end
}
end

function newcucumber(y, temp) 
	local x, width, height = frame_width, cucumber_img:getWidth(), cucumber_img:getHeight()
	return {
	wait_element = nil,
	points = -50,
	draw = function()
		love.graphics.draw(cucumber_img, x, y)
	end,
	update = coroutine.wrap(function (self, dt, index)
		while true do
		 	x = x - 4 
		 	if (x < 0) then
		 		print("remove elemento de index igual a", index)
		 		print(debug_percorre(active_elements))
		 		table.remove(active_elements, index)
		 		print("depois da remocao - qtd de elementos ativos", #active_elements)
		 	end
		 	wait(temp/1000, self)
		 end
	end),
	pos = function ()
 		return x+(width/2), y+(height/2)
 	end

}
end

function wait(temp, element)
	element.wait_element = curr_time + temp
	coroutine.yield()
end

function debug_percorre(list)
	print("debug: imprimindo lista")
	if next(list) then
		print(list[i])
	end
end

function is_empty(list)
	if next(list) == nil then
   		return true
	end
	return false
end


function love.load()
  math.randomseed(os.time()) -- seta seed para pegar numeros randomicos
  -- criacao das fontes e imagens
  font1 = love.graphics.newFont("fonts/m04.TTF", 27)
  cat_img = love.graphics.newImage("imgs/cat.png")
  taco_img = love.graphics.newImage("imgs/taco.png")
  cucumber_img = love.graphics.newImage("imgs/cucumber.png")

  -- cria personagem e lista de elementos
  cat = newcat() 
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
		elements[i] = newcucumber(math.random(5, frame_height-cucumber_img:getHeight()+3), i+math.random(1, 10))
	end
	for i = 11, 25 do
		elements[i] = newtaco(math.random(5, frame_height-taco_img:getHeight()+3), i+math.random(1, 10))
	end
	print("criei elementos", #elements)
end

function love.draw()
  -- background e display do score
  love.graphics.setBackgroundColor(152, 242, 234)
  love.graphics.setColor(255,255,255)
  love.graphics.setFont(font1)
  love.graphics.print("Score: ".. cat.score, 16, 16)

  -- desenha elementos ativos
  cat.draw()

  for i, element in ipairs(active_elements) do
  	--if element then 
  		element.draw()
  	--end
  end
end

function love.update(dt)
	curr_time = curr_time + dt

	if love.keyboard.isDown('right') then
		if is_empty(active_elements) then
			-- se lista de elementos ativos esta vazia, ainda ha elementos criados ainda nao usados?
			print("lista de elementos ativos eh vazia")
			if is_empty(elements) then
				-- se nao ha, cria novos elementos
				print("lista de elementos existentes eh vazia")
				create_elements()
			else
				-- se ha, escolhe dentre os existentes, novos elementos ativos
				print("lista de elementos existentes n eh vazia - escolhe novos para ativos")
				print("numero de elementos existentes", #elements)
				num = math.random(#elements/2)
				print("quantidade de escolhidos", num)
				for i = 1, num do
					print("chamei a pick active", i)
					pick_active_elements()
				end
			end
		else 
			-- se lista de elementos ativos nao eh vazia, chama update caso o elemento nao esteje em espera ou sua espera acabou
			print("lista de ativos nao eh vazia", #active_elements)
			for i in ipairs(active_elements) do
				if not active_elements[i].wait_element then
					active_elements[i]:update(dt, i)
				else
					if(curr_time >= active_elements[i].wait_element) then
						active_elements[i].wait_element = nil
						active_elements[i]:update(dt, i)
					end
				end
			end
		end
		
	-- se o usuario aperto space, faz o gato pular
	elseif love.keyboard.isDown('space') then
		cat.y_velocity = cat.jump_height
	end

	cat.update(dt)

	-- para cada elemento ativo, verifica se gato colidiu com o mesmo. se sim, remove elemento da lista de ativos e atualiza score
	for i, element in ipairs(active_elements) do
		if element then 
			local posx, posy = element.pos()
			if cat.affected(posx, posy) then
				cat.score = cat.score + element.points
				table.remove(active_elements, i)
			end
		end
	end

end
