local frame_width, frame_height = love.graphics.getDimensions( )
local static_elements = {}
local moving_elements = {}
local element_type = {}
local curr_time = 0


function love.load()
  -- seta seed para pegar numeros randomicos
  math.randomseed(os.time()) 
  math.random(); math.random(); math.random()

  -- flag de pausa
  pause = false

  -- flag de gameOver
  gameOver = false

  -- fonte do jogo
  font1 = love.graphics.newFont("fonts/m04.TTF", 27)

  -- imagens
  cat_img = love.graphics.newImage("imgs/cat.png")
  taco_img = love.graphics.newImage("imgs/taco.png")
  cucumber_img = love.graphics.newImage("imgs/cucumber.png")
  chili_img = love.graphics.newImage("imgs/chili.png")
  fullheart_img = love.graphics.newImage("imgs/fullheart.png")
  emptyheart_img = love.graphics.newImage("imgs/emptyheart.png")
  cloud_img = love.graphics.newImage("imgs/cloud.png")

  -- sons
  backgroundSong = love.audio.newSource("audio/background.wav")
  backgroundSong:play()
  backgroundSong:setLooping(true)
  overSong = love.audio.newSource("audio/over.wav", "static")

  --tipos de elementos: imagem e pontuação
  element_type[1] = {taco_img, 30}
  element_type[2] = {cucumber_img, -50}
  element_type[3] = {chili_img, 60}

  -- cria jogador
  cat = newcat() 

  -- cria nuvens do background
  create_clouds()
end

function love.update(dt)
	if not pause then
		local dis = -1
		local right = love.keyboard.isDown('right')
		local left = love.keyboard.isDown('left')

		curr_time = curr_time + dt

		-- game over se nao tem mais vida
		if cat.lives == 0 then
			gameOver = true
			overSong:play()
		end

		-- update e criacao de elementos
		if is_empty(static_elements) then 
			create_static_elements()
		end

		if is_empty(moving_elements) then
			create_moving_elements()
		else
			update_list_elements(dt, moving_elements, dis)
		end
		
		-- locomocao de jogador e elementos estaticos
		if right or left then
			if left then 	
				dis = 1
			end
			-- se lista de elementos nao eh vazia, chama update caso o elemento nao esteje em espera ou sua espera acabou
			update_list_elements(dt, static_elements, dis)
			cloud1:update(dis)
 			cloud2:update(dis)
		-- se o usuario aperto space, faz o gato pular
		elseif love.keyboard.isDown('space') then
			cat.y_velocity = cat.jump_height
		end

		cat.update(dt)

		-- para cada elemento, verifica se gato colidiu com o mesmo
		check_collision(static_elements)
		check_collision(moving_elements)
	end
	if gameOver then
		pauseAndOver()
	end
end

function love.draw()
	if not gameOver then
		-- fundo e score
		love.graphics.setBackgroundColor(152, 242, 234)
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(font1)
		love.graphics.print("Score: ".. cat.score, 16, 16)

		-- desenha nuvens do background
		cloud1.draw()
		cloud2.draw()

		-- vidas restantes
		local x = frame_width-fullheart_img:getWidth()
		local y = 3
		for i = 1, cat.lives do
			love.graphics.draw(fullheart_img, x, y)
			x = x-fullheart_img:getWidth()
		end
		-- vidas perdidas
		local cont = 7-cat.lives
		while cont ~= 0 and cat.lives > 0 do
			love.graphics.draw(emptyheart_img, x, y)
			x = x-fullheart_img:getWidth()
			cont = cont - 1
		end

		-- jogador
		cat.draw()

		-- elementos
		for i in ipairs(static_elements) do
			static_elements[i].draw()
		end

		for i in ipairs(moving_elements) do
			moving_elements[i].draw()
		end
	else 
		-- se flag de gameOver for true, desenha tela de gameOver
  		love.graphics.setBackgroundColor(0, 0, 0, 0.6)
  		love.graphics.print("Game Over", frame_width/2-125, frame_height/2)	
	end
end

-- criaçao de elementos estaticos
function create_static_elements () 
	for i = 1, math.random(6) do
		local random_type = element_type[math.random(#element_type)]
		static_elements[i] = newelement(random_type[1], random_type[2])
	end
end

-- criacao de elementos dinamicos
function create_moving_elements() 
	local j = math.random(5)
	for i=1, j do
		local random_type = element_type[math.random(#element_type)]
		moving_elements[i] = newelement(random_type[1], random_type[2])
	end
end

-- função que verifica se gato colidiu com algum elemento. se sim, atualiza score  se for pepino tira uma vida
function check_collision(list)
	for i, element in ipairs(list) do
		if element then
			local posx, posy = element.pos()
				if cat.affected(posx, posy) then
					-- incrementa score
					cat.score = cat.score + element.points
					-- verifica se elemento é um pepino
					if(element.points == element_type[2][2]) then
						cat.lives = cat.lives - 1
					end
					table.remove(list, i)
				end
		end
	end
end

-- chama update de elementos que já podem ser atualziados
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


function newcat ()
  local x, width, height = 100, cat_img:getWidth(), cat_img:getHeight()
  local y = frame_height-(height+3)

  return {
  score = 0,
  lives = 7,
  ground = y,
  y_velocity = 0,
  jump_height = -300,
  gravity = -900,
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
		 	if (x < 0) then
		 		-- verifica qual lista de elementos ele pertence para entao remove-lo
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

function cloud(img, x, y) 
	local width, height = img:getWidth(), img:getHeight()
	local original_x = x
	return {
	draw = function()
		love.graphics.draw(img, x, y)
	end,
	update = function(self, dis)
		x = x + dis*5
		if x < 0 then
			x = original_x
		end
	end
	}
 end

 function create_clouds()
 	local x = frame_width
 	local y = cloud_img:getHeight()+10
 	cloud1 = cloud(cloud_img, x, y)
 	cloud2 = cloud(cloud_img, x+200, y+250)
 end

function wait(temp, element)
	element.wait_element = curr_time + temp
	return coroutine.yield()
end

-- indica se uma table esta vazia
function is_empty(list)
	if next(list) == nil then
   		return true
	end
	return false
end


-- indica se uma table contem um valor
function contains_value(list, val)
	for index, value in ipairs(list) do
        if value == val then
            return true
        end
    end
    return false
end

-- funcao de gameOver que pausa e espera pela tecla esc para finalizar o jogo
function pauseAndOver () 
	pause = true
	backgroundSong:pause()
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end

-- callback para pausar jogo
function love.keyreleased( key )
	if key == "p" then
		pause = not pause
	end
end