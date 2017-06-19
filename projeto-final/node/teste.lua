wificonf = {
  ssid = "Alice",
  pwd = "19601990",
  save = false
}

led1 = 3
local lastLocation
gpio.write(led1, gpio.LOW)

MQTT_HOST = "10.0.0.8"
srv = net.createServer(net.TCP)
local m = mqtt.Client("node-will", 120)

--[[local acoes = {
  LIGALED = gpio.write(led1, gpio.HIGH),
  DESLIGALED = gpio.write(led1, gpio.LOW)
}]]--

function novaInscricao (c)
  function novamsg (c, t, acao)
    --[[print ("acao ".. acao)
    local executaAcao = acoes[acao]
    if executaAcao then
      executaAcao()
    end]]--
    print("entrei!")
  end
  c:on("message", novamsg)
end

function conectado (client)
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
