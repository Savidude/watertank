TRIGGER = 5
ECHO = 4

tank_height = 100;

pulse_time = 0

gpio.mode(TRIGGER, gpio.OUTPUT)
gpio.mode(ECHO, gpio.INPUT)

gpio.trig(ECHO, "up", startDis)
gpio.trig(ECHO, "down", endDis)

client_connected = false
m = mqtt.Client("ESP8266-" .. node.chipid(), 120, "${DEVICE_TOKEN}", "")

function startDis(level)
    print("something")
    time=tmr.now()
end    

function endDis(level)
    print("something")
    time=tmr.now()-time

    distance = tank_height - (time/40)

    if (client_connected) then
        local payload = "{event:{metaData:{owner:\"${DEVICE_OWNER}\",deviceId:\"${DEVICE_ID}\"}, payloadData:{waterlevel:" ..distance.. "}}}"
        m:publish("carbon.super/watertank/${DEVICE_ID}/waterlevel", payload, 0, 0, function(client)
            print("Published")
        end)
    else
        connectMQTTClient()
    end
    
    print(time)
    flag=0
end 

function connectMQTTClient()
    local ip = wifi.sta.getip()
    if ip == nil then
        print("Waiting for network")
    else
        print("Client IP: " .. ip)
        print("Trying to connect MQTT client")
        m:connect("${MQTT_EP}", ${MQTT_PORT}, 0, function(client)
            client_connected = true
            print("MQTT client connected")
--            subscribeToMQTTQueue()
        end)
    end
end

tmr.alarm(0, 5000, 1, function()
    print("loop")
    duration = 0;
    distance = 0;

    gpio.write(TRIGGER, gpio.LOW)
    tmr.delay(2)
    gpio.write(TRIGGER, gpio.HIGH)
    
    tmr.delay(10)
    gpio.write(TRIGGER, gpio.LOW)

    --delete this
    distance = math.random(0,100)
    
    if (client_connected) then
        local payload = "{event:{metaData:{owner:\"${DEVICE_OWNER}\",deviceId:\"${DEVICE_ID}\"}, payloadData:{waterlevel:" ..distance.. "}}}"
        m:publish("carbon.super/watertank/${DEVICE_ID}/waterlevel", payload, 0, 0, function(client)
            print("Published")
        end)
    else
        connectMQTTClient()
    end
end)
