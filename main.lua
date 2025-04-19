local socket = require "socket"
local updaterate = 1
local t = 0
local connected = false

-- host or join locally
local udp = socket.udp()
udp:settimeout(0)
udp:setsockname("127.0.0.1", 14285)
if not udp:getsockname() then
  -- join
    udp:setpeername("127.0.0.1", 14285)
    udp:send("join")
    connected = true
end

function love.update(deltatime)
    if not connected then
        -- wait for somebody to join
        repeat
            local data, ip, port = udp:receivefrom()
            if data == "join" then
                udp:setpeername(ip, port)
                connected = true
                print("connected!")
                break
            end
        until not data
    else
        repeat
            local data = udp:receive()
            if data then
                print(data)
            end
        until not data
        t = t + deltatime
        if t > updaterate then
            print("sending message")
            udp:send("message from across the wire")
            t = t - updaterate
        end
    end
end

function love.draw()
    love.graphics.print("network test")
end
