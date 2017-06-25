wificonf = {
  ssid = "GUTO",
  pwd = "53057611",
  save = false
}

led1 = 3
help_button = 1

gpio.mode(led1, gpio.OUTPUT)
gpio.write(led1, gpio.LOW);
gpio.mode(help_button, gpio.INT, gpio.PULLUP)

MQTT_HOST = "192.168.0.13"
local m = mqtt.Client("node-will", 120)

local lastLocation;

local function willwrite (led, s)
  return function () 
           gpio.write(led, s) 
         end
end


function enviarLocalizacao(origem)
  lastLocation = "lon=-22.979239399999997;lat=-43.232571199999995"
  m:publish("localizacao",lastLocation..origem,0,0, 
            function(client) print("mandou localizacao!") end) 
end

function publicaSensor() 
  math.randomseed(tmr.time()) 
  math.random(); math.random(); math.random()
  local distancia = 20
  distancia = distancia + math.random(0, 20)
  m:publish("sensor", distancia, 0,0, function(client) print("mandou sensor!") end)
end

acoes = {
  LIGALED =  function() gpio.write(led1, gpio.HIGH) end,
  DESLIGALED = function() gpio.write(led1, gpio.LOW) end,
  LOCALIZACAO = function() enviarLocalizacao("pedido") end
}

-- se o botao for pressionado, envia localizacao
gpio.trig(help_button, "down", function(level)
       enviarLocalizacao("botaoajuda") end) 

function novaInscricao (c)
  function novamsg (c, t, acao)
    print ("acao ".. acao)
    local executaAcao = acoes[acao]
    if executaAcao then
      executaAcao()
    end
  end
  c:on("message", novamsg)
end

-- cada 2s publica dado do sensor 
temp = tmr.create()
temp:register(2000, tmr.ALARM_AUTO,
      function (timer)
        publicaSensor()
      end)

function conectado (client)
  temp:start()
  client:subscribe("acoes", 0, novaInscricao)
end 

function connectedToWifi()
  print('Connected to wifi. IP: ')
  local ip, _, _ = wifi.sta.getip()
  print(ip)
  
  m:connect(MQTT_HOST, 1883, 0, 
            conectado,
             function(client, reason) print('failed reason: '..reason) end)
end

print('Connecting to wifi...')
wifi.sta.config(wificonf)
wifi.setmode(wifi.STATION)
tmr.create():alarm(8000, tmr.ALARM_SINGLE, connectedToWifi)