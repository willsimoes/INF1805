wificonf = {
  -- verificar ssid e senha
  ssid = "guto",
  pwd = "53057611",
  save = false
}


wifi.sta.config(wificonf)
print("modo: ".. wifi.setmode(wifi.STATION))
print(wifi.sta.getip())
