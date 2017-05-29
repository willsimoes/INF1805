led1 = 3
local srvIP = "192.168.0.20"
local lastLocation;

srv = net.createServer(net.TCP)

local m = mqtt.Client("node-w", 120)

gpio.write(led1, gpio.LOW);
gpio.mode(1, gpio.INT, gpio.PULLUP)
gpio.trig(1, "down", function(level)
       m:publish("botaoajuda", "ajuda", 0,0, 
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

if srv then
  srv:listen(80, srvIP, function(conn)
      print("estabeleceu conexÃ£o")
      conn:on("receive", receiver)
    end)
end

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")