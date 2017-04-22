local frame_width, frame_height = love.graphics.getDimensions( )
local grass_height = 30

function newcat ()
  local x, width, height = 0, 100, 50
  local y = frame_height-(grass_height+height+3)
  return {
  draw = function () 
    love.graphics.rectangle("line", x, y, width, height)
  end,
  update = function (dt) 
    if(x < 200) then 
      x = x + 0.5
    end
  end
}
end

-- criação de todos os "objetos"
function love.load()

  cat = newcat()
  
end

-- desenha todos eles a cada frame
-- chama todas as funções draw de cada "objeto"
function love.draw()
  local y = frame_height-grass_height
  love.graphics.line(0, y, frame_width, y)
  cat.draw()


end

-- chamado em cada frame para atualizar o jogo
function love.update(dt)
  cat.update(dt)
end
