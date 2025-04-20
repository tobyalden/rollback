local socket = require "socket"
local updaterate = 1
local t = 0
local connected = false
local p1  =  {x = 100, y = 100}
local p2  =  {x = 300, y = 200}
local frame = 1
local local_input_history = {}
local remote_input_history = {}

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
            local receive_data = udp:receive()
            if receive_data then
                print("receive: %s", receive_data)
            end
        until not data
        t = t + deltatime
        if t > updaterate then
            local_input_history[frame] = {}
            local_input_history[frame].left = love.keyboard.isDown("left")
            local_input_history[frame].right = love.keyboard.isDown("right")
            local_input_history[frame].up = love.keyboard.isDown("up")
            local_input_history[frame].down = love.keyboard.isDown("down")
            local send_data = serialize_input_history(local_input_history)
            print("sending: %s", send_data)
            udp:send(send_data)
            t = t - updaterate
            frame = frame + 1
        end
    end
end

function love.draw()
    love.graphics.print("network test")
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", p1.x, p1.y, 16, 16)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", p2.x, p2.y, 16, 16)
end

function serialize_input_history(input_history)
    local serialized_input_history = ''
    for frame, inputs in pairs(input_history) do
        local serialized_inputs = ''
        for _, input in pairs({"left", "right", "up", "down"}) do
            local serialized_input = "0"
            if inputs[input] then
                serialized_input = "1"
            end
            serialized_inputs = serialized_inputs..serialized_input
        end
        serialized_inputs = string.format("%d-%s--", frame, serialized_inputs)
        serialized_input_history = serialized_input_history..serialized_inputs
    end
    return serialized_input_history
end

--function deserialize_inputs(serialized_inputs)
    --local inputs = {}
    --for i, input in ipairs({"left", "right", "up", "down"}) do
        --inputs[input] = string.sub(serialized_inputs, i, i) == "1"
    --end
    --return inputs
--end
