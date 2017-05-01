local frame_width, frame_height = love.graphics.getDimensions( )
local static_elements = {}
local moving_elements = {}
local element_type = {}
local curr_time = 0;


function love.load()
  math.randomseed(os.time()) -- seta seed para pegar numeros randomicos
  math.random(); math.random(); math.random()
  -- criacao das fontes e imagens
  font1 = love.graphics.newFont("fonts/m04.TTF", 27)

  cat_img = love.graphics.newImage("imgs/cat.png")

  taco_img = love.graphics.newImage("imgs/taco.png")
  cucumber_img = love.graphics.newImage("imgs/cucumber.png")
  chili_img = love.graphics.newImage("imgs/chili.png")

  element_type[1] = {taco_img, 30}
  element_type[2] = {cucumber_img, -40}
  element_type[3] = {chili_img, 60}

  -- cria personagem e lista de elementos
  cat = newcat() 
  --create_static_elements()
end

function create_static_elements () 
	for i = 1, math.random(6) do
		local random_type = element_type[math.random(#element_type)]
		static_elements[i] = newelement(random_type[1], random_type[2])
	end
end

function create_moving_elements() 
	print("criando elemenetos moving")
	local j = math.random(4)
	for i=1, j do
		local random_type = element_type[math.random(#element_type)]
		moving_elements[i] = newelement(random_type[1], random_type[2])
	end
end


function love.update(dt)
	local dis = -1
	local right = love.keyboard.isDown('right')
	local left = love.keyboard.isDown('left')

	curr_time = curr_time + dt

	if is_empty(static_elements) then 
		create_static_elements()
	end

	if is_empty(moving_elements) then
		print("empty")
		create_moving_elements()
	else
		print("updatando moving elements")
		update_list_elements(dt, moving_elements, dis)
	end

	

	if right or left then
		if left then 	
			dis = 1
		end
		-- se lista de elementos nao eh vazia, chama update caso o elemento nao esteje em espera ou sua espera acabou
		update_list_elements(dt, static_elements, dis)
	-- se o usuario aperto space, faz o gato pular
	elseif love.keyboard.isDown('space') then
		cat.y_velocity = cat.jump_height
	end

	cat.update(dt)

	-- para cada elemento, verifica se gato colidiu com o mesmo. 
	-- se sim, remove elemento da lista e atualiza score
	check_collision(static_elements)
	check_collision(moving_elements)

end

function check_collision(list)
	for i, element in ipairs(list) do
		if element then
			local posx, posy = element.pos()
				if cat.affected(posx, posy) then
					cat.score = cat.score + element.points
					table.remove(list, i)
				end
		end
	end
end

function update_list_elements (dt, list, dis)
	for i in ipairs(list) do	
		if not list[i].wait_element then
			list[i]:update(dt, i, dis*4)
		elseif (curr_time >= list[i].wait_element) then
			list[i].wait_element = nil
			list[i]:update(dt, i, dis*4)
		end
	end	
end

function love.draw()
  -- background e display do score
  love.graphics.setBackgroundColor(152, 242, 234)
  love.graphics.setColor(255,255,255)
  love.graphics.setFont(font1)
  love.graphics.print("Score: ".. cat.score, 16, 16)

  -- desenha elementos ativos
  cat.draw()

  for i in ipairs(static_elements) do
  	static_elements[i].draw()
  end

  for i in ipairs(moving_elements) do
  	moving_elements[i].draw()
  end
end

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
  	-- velocidade do eixo y do gato n eh zero, aplica o peso do pulo na posição e tambem o peso da gravidade na velocidade
  	if cat.y_velocity ~= 0 then
  		y = y + cat.y_velocity * dt          
		cat.y_velocity = cat.y_velocity - cat.gravity * dt 
	end
	    
	-- se a posição dele colidir com o chao, ele retornou ao chao - seta velocidade do eixo y para 0
    if y > cat.ground then    
		cat.y_velocity = 0       
    	y = cat.ground    
	end

	-- se ele colidiu com o "teto", seta a posicao y no teto
	if y < 0 then
		y = 3
	end
  end,
  -- verifica se o gato colidiu com o elemento de posx e posy
  affected = function (posx, posy) 
  	if posx>x and posx<x+width and posy>y and posy<y+height then
  		return true
  	else
  		return false
  	end
  end
}
end

function newelement(img, num_points) 
	local x, width, height = frame_width, img:getWidth(), img:getHeight()
	local y = math.random(3,frame_height-height)
	return {
	wait_element = nil,
	points = num_points,
	draw = function()
		love.graphics.draw(img, x, y)
	end,
	update = coroutine.wrap ( function (self, dt, index, dis)
		while true do
		 	x = x + dis*index
		 	print(x)
		 	if (x < 0) then
		 		if contains_value(moving_elements, self) then
		 			table.remove(moving_elements, index)
		 		else
		 			table.remove(static_elements, index)
		 		end
		 	end
		 	_, _, index, dis = wait(index/1000, self)
		end
	end),
	pos = function ()
 		return x+(width/2), y+(height/2)
 	end

}
end

function wait(temp, element)
	element.wait_element = curr_time + temp
	return coroutine.yield()
end

function is_empty(list)
	if next(list) == nil then
   		return true
	end
	return false
end

function contains_value(list, val)
	for index, value in ipairs(list) do
        if value == val then
            return true
        end
    end
    return false
end