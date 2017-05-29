require('lure//lure.lua')

led1 = 3
local srvIP = "192.168.0.20"
local lastLocation;

gpio.write(led1, gpio.LOW);
gpio.mode(1, gpio.INT, gpio.PULLUP)
gpio.trig(1, "down", function(level)
       m:publish("botaoajuda", lastLocation,0,0, 
            function(client) print("mandou!") end) 
       end)

local acoes = {
  LIGALED = gpio.write(led1, gpio.HIGH)
  DESLIGALED = gpio.write(led1, gpio.LOW)
  LOCALIZACAO = enviarLocalizacao 
}

function enviarLocalizacao()
  m:publish("localizacao",lastLocation,0,0, 
            function(client) print("mandou!") end) 
end

local m = mqtt.Client("node-w", 120)

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, acao)
    print ("acao ".. acao)
    local executaAcao = acoes[acao]
    if executaAcao then
      executaAcao()
    end
  end
  c:on("message", novamsg)
end

function conectado (client)
  client:subscribe("acoes", 0, novaInscricao)
end 

m:connect("192.168.0.2", 1883, 0, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)
