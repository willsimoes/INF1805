
local m = mqtt.Client("clientid", 120)

function publica(c)
  c:publish("alos","alo do nodemcu!",0,0, 
            function(client) print("mandou!") end)
end

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function conectado (client)
  publica(client)
  client:subscribe("alos", 0, novaInscricao)
end 

m:connect("192.168.0.2", 1883, 0, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)



        


