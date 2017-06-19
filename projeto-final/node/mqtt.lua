wificonf = {
  ssid = "Alice",
  pwd = "19601990",
  save = false
}

led1 = 3
local lastLocation;

MQTT_HOST = "10.0.0.8"
srv = net.createServer(net.TCP)
local m = mqtt.Client("node-will", 120)

-- cada 2s publica dado do sensor 
temp = tmr.create()
temp:register(2000, tmr.ALARM_AUTO,
      function (timer)
        publicaSensor()
      end)

-- se o botao for pressionado, envia localizacao
gpio.write(led1, gpio.LOW);
gpio.mode(1, gpio.INT, gpio.PULLUP)
gpio.trig(1, "down", function(level)
       enviarLocalizacao("botaoajuda") end) 

function enviarLocalizacao(origem)
  if lastLocation == nil then
    lastLocation = "LOCALIZAÇÃO AINDA NÃO ENVIADA"
  end
  m:publish("localizacao",lastLocation..origem,0,0, 
            function(client) print("mandou localizacao!") end) 
end

local acoes = {
  LIGALED = gpio.write(led1, gpio.HIGH),
  DESLIGALED = gpio.write(led1, gpio.LOW),
  LOCALIZACAO = enviarLocalizacao("pedido") 
}

function publicaSensor() 
  math.randomseed(tmr.time()) 
  math.random(); math.random(); math.random()
  local distancia = 20
  distancia = distancia + math.random(0, 20)
  m:publish("sensor", distancia, 0,0, function(client) print("mandou sensor!") end)
end

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

function receiver(sck, request)

  -- analisa pedido para encontrar valores enviados
  local _, _, method, path, vars = string.find(request, "([A-Z]+) ([^?]+)%?([^ ]+) HTTP");
  -- se nao conseguiu casar, tenta sem variaveis
  print(method, path, vars)
  if(method == nil)then
    _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
     print(method, path)
  end
  
  if (vars ~= nil) then
    lastLocation = vars
  end

  local buf = [[
<div id="mensagem"></div>
  <script>

  window.onload = sendLocation();
  
  var mensagem = document.getElementById("mensagem");

  function sendLocation () {
      if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(doGetLocation,showError);
        } else { 
            mensagem.innerHTML = "Geolocation is not supported by this browser.";
        }
    }

    function doGetLocation(position) {  
    var req = new XMLHttpRequest();

    req.open("GET", getLocation(position) , true);

    req.onreadystatechange = function() {
      //se a requisição foi concluída e se a resposta do servidor foi recebida com sucesso
      if (req.readyState == 4 && req.status == 200) {
        //chama sendLocation a cada 2 minutos
        setTimeout(sendLocation, 120000);
      }
    }
  }

    function getLocation(position) {
      var valueData = getData();
      var valueLon = position.coords.latitude;
      var valueLat = position.coords.longitude;

      return "?lon=" + valueLon + "&lat=" + valueLat + "&data=" + valueData; 
    }

    function sendFakeLocation () {
      var valueData = getData();
      valueLon = -22.979239399999997;
      valueLat = -43.232571199999995;
      location.href = "?lon=" + valueLon + "&lat=" + valueLat + "&data=" + valueData; 
    }

    function getData() {
      var dataSinal = new Date();
      var dd = addZero(dataSinal.getDate());
      var MM = addZero(dataSinal.getMonth()+1);
      var yyyy = dataSinal.getFullYear();
      var HH = addZero(dataSinal.getHours());
      var mm = addZero(dataSinal.getMinutes());
      var ss = addZero(dataSinal.getSeconds());
      
      return dd + "/" + MM +"/" + yyyy + "$" + HH + ":" + mm + ":" + ss;
    }

    function addZero(i) {
        if (i < 10) {
            i = "0" + i;
        }
        return i;
    }

    function showError(error) {
        switch(error.code) {
            case error.PERMISSION_DENIED:
                mensagem.innerHTML = "User denied the request for Geolocation."
                setTimeout(sendFakeLocation, 120000);
                break;
            case error.POSITION_UNAVAILABLE:
                mensagem.innerHTML = "Location information is unavailable."
                break;
            case error.TIMEOUT:
                mensagem.innerHTML = "The request to get user location timed out."
                break;
            case error.UNKNOWN_ERROR:
                mensagem.innerHTML = "An unknown error occurred."
                break;
        }
    }
</script>
]]

  sck:send(buf, function() print("respondeu") sck:close() end)
end

print('Connecting to wifi...')
wifi.sta.config(wificonf)
wifi.setmode(wifi.STATION)
tmr.create():alarm(8000, tmr.ALARM_SINGLE, connectedToWifi)

if srv then
  srv:listen(80, "10.0.0.10", function(conn)
      print("estabeleceu conexÃ£o")
      conn:on("receive", receiver)
    end)
end

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")