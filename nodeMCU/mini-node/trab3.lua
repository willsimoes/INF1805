srv = net.createServer(net.TCP)

local lon, lat, dt, hora;

function receiver(sck, request)

  -- analisa pedido para encontrar valores enviados
  local _, _, method, path, vars = string.find(request, "([A-Z]+) ([^?]+)%?([^ ]+) HTTP");
  -- se nÃ£o conseguiu casar, tenta sem variÃ¡veis
  print(method, path, vars)
  if(method == nil)then
    _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
     print(method, path)
  end
  
  local sinal = {}
  
  if (vars ~= nil) then
    for k, v in string.gmatch(vars, "([^=]+)=([^=]+)&") do
      sinal[k] = v
      print (k, sinal[k])
    end
  end

  if(sinal["data"] ~= nil) then
    _, _, dt, hora = string.find(sinal["data"], "(%d+/%d+/%d+)$(.+)");
  end


  local buf = [[

  <button id="location-button"><b>ENVIAR LOCALICACAO</b></button>
  <div id="mensagem"></div>

  <script>
    document.getElementById("location-button").onclick = sendLocation;

    function sendLocation () {
      if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(getLocation,showError);
        } else {
            mensagem.innerHTML = "Geolocation is not supported by this browser.";
        }
    }

    function getLocation(position) {

      var valueData = getData();
     
      var valueLon = position.coords.latitude;
      var valueLat = position.coords.longitude;

      location.href = "?lon=" + valueLon + "&lat=" + valueLat + "&data=" + valueData + "&"; 
    }

    function sendFakeLocation () {
      var valueData = getData();
      valueLon = -22.979239399999997;
      valueLat = -43.232571199999995;
      location.href = "?lon=" + valueLon + "&lat=" + valueLat + "&data=" + valueData + "&"; 
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
                sendFakeLocation();
                break;
            case error.POSITION_UNAVAILABLE:
                mensagem.innerHTML = "Location information is unavailable."
                sendFakeLocation();
                break;
            case error.TIMEOUT:
                mensagem.innerHTML = "The request to get user location timed out."
                sendFakeLocation();
                break;
            case error.UNKNOWN_ERROR:
                mensagem.innerHTML = "An unknown error occurred."
                sendFakeLocation();
                break;
        }
    }
</script>
]]

  sck:send(buf, function() print("respondeu") sck:close() end)
end

if srv then
  srv:listen(80,"192.168.0.20", function(conn)
      print("estabeleceu conexÃ£o")
      conn:on("receive", receiver)
    end)
end

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")