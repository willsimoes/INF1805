require('lure//lure.lua')
JSON = (loadfile "JSON.lua")()

MQTT = require("mqtt_library")
MQTT.Utility.set_debug(true)

topics = { "botaoajuda", "localizacao" }

client = MQTT.client.create("localhost", 1833, callback)
client:subscribe(topics)

function callback(topic, message)
    print("Received: " .. topic .. ": " .. message)
    if topic == "botaoajuda" then 
      client:publish("acoes", "LOCALIZACAO")
    else if topic == "localizacao"
        local sinal = {}
    
        if (lastLocation ~= nil) then
          for k, v in string.gmatch(lastLocation, "([^=]+)=([^=]+)&") do
            sinal[k] = v
            print (k, sinal[k])
          end
        end

        local endereco = processarLocalizacao(sinal["lon"], sinal["lat"])

        if(sinal["data"] ~= nil) then
          _, _, dt, hora = string.find(sinal["data"], "(%d+/%d+/%d+)$(.+)");
        end

        local info = "Usuário localizado em: "  + endereco + " às " + hora + " do dia " + dt;

        client:publish("monitoramento", info)
    end
end


function processarLocalizacao(lon, lat)
  req = XMLHttpRequest.new()
 
  local caminho = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' + lon + ',' + lat;
  --create a new request, set method, url, and sync option
  req.open('GET', caminho, true);

  req.onReadyStateChange = function() 
    if req.readyState == 4 and req.status == 200 then
      local jsonTable= JSON:decode(req.responseText)
      local results = jsonTable["results"]
      local result = results[0]
      return result["formatted_address"]
    end
  end

  req.send();
end