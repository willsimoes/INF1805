function love.update(dt)
    c:handler()
end

function love.draw()
  
end

function love.load()
   MQTT = require("mqtt_library")
   --MQTT.Utility.set_debug(true)

   -- callback chamada quando mensagens dos topicos chegam
   callback = function (topic, message)
       --print("Received from " .. topic .. ": " .. message)
       if topic == "dados_ultrassonico" then
       	   print("---------------------------------------------------")
           print("Processando dados do sensor de distancia. Mensagem: " .. message)
           -- "processa" dado do sensor
           local delta_tempo = tonumber(message)
           local distance_cm = delta_tempo / 29.4
           print("Calculo da distancia: ".. distance_cm)
           if distance_cm <= 25 then
               c:publish("acoes", "LIGALED")
               c:publish("acoes", "TOCABUZZER")
           elseif distance_cm > 25 then
               c:publish("acoes", "DESLIGALED")
               c:publish("acoes", "PARABUZZER")
           end
       elseif topic == "dados_acelerometro" then
       	  print("---------------------------------------------------")
          print("Processando dados do acelerometro. Mensagem: " .. message)
          Ax, Ay, Az = message:match("(.*):(.*):(.*)")
          print("Ax:"..Ax.."     Ay:"..Ay.."      Az:"..Az)
          local vector_sum = math.sqrt(Ax*Ax + Ay*Ay + Az*Az)
          print("Calculo queda:  "..vector_sum)
          if vector_sum <= 3 then
            print("Publica evento de queda")
            c:publish("eventos", "queda")
          end
       elseif message == "quit" then 
         running = false
         c:unsubscribe(topics)
       end
   end

   -- topicos que gerenciador vai assinar
   topics = { "dados_ultrassonico", "dados_acelerometro" }

   c = MQTT.client.create("localhost", 1883, callback)
   --print(c)
   result = c:connect("gerenciador-id")
   --print(result)
   c:subscribe(topics)
end