-- cofiguração wifi
wificonf = {
  ssid = "VIVO-A5BC",
  pwd = "J629049130",
  save = false
}

-- definico do led, pinos e buzina
led1 = 3
help_button = 1
buzzer = 7

-- incializando led, buzina e interrupção para o botão de ajuda
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(buzzer, gpio.OUTPUT)
gpio.write(led1, gpio.LOW)
gpio.write(buzzer, gpio.LOW);
gpio.mode(help_button, gpio.INT, gpio.PULLUP)

MQTT_HOST = "192.168.15.80"
local m = mqtt.Client("node-will", 120)

function publicaDadosUltrassonico(delta_t) 
  m:publish("dados_ultrassonico", delta_t, 0,0, function(client) print("mandou dados sensor de distancia!") end)
end

function publicaDadosAcelerometro(three_axis) 
  m:publish("dados_acelerometro", three_axis, 0,0, function(client) print("mandou dados acelerometro!") end)
end

acoes = {
  LIGALED =  function() gpio.write(led1, gpio.HIGH) end,
  DESLIGALED = function() gpio.write(led1, gpio.LOW) end,
  TOCABUZZER = function() gpio.write(buzzer, gpio.HIGH) end,
  PARABUZZER = function() gpio.write(buzzer, gpio.LOW) end,
}

-- se o botao for pressionado, publica no topico o evento de ajuda
gpio.trig(help_button, "down", function(level)
       print("Botao de ajuda, entrou aqui!")
       m:publish("eventos", "ajuda", 0, 0, function(client) print("mandou evento de ajuda!") end) end)

-- callback de inscrição do topico de ação
function executarAcao (c)
  function novamsg (c, t, acao)
    if acao ~= "LOCALIZAR" then
      print ("acao ".. acao)
      local executaAcao = acoes[acao]
      if executaAcao then
          executaAcao()
      end
    end
  end
  c:on("message", novamsg)
end

--assina topico de acoes
function conectado (client)
  client:subscribe("acoes", 0, executarAcao)
end 

function connectedToWifi()
  print('Connected to wifi. IP: ')
  local ip, _, _ = wifi.sta.getip()
  print(ip)

  if ip ~= nil then
  	start_devices()
  end
  
  m:connect(MQTT_HOST, 1883, 0, 
            conectado,
             function(client, reason) print('failed reason: '..reason) end)
end

print('Connecting to wifi...')
wifi.sta.config(wificonf)
wifi.setmode(wifi.STATION)
tmr.create():alarm(8000, tmr.ALARM_SINGLE, connectedToWifi)