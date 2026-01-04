
cutscene_text = "    on 22 september 1932\n  naturalist william beebe\n  onboard his \"bathysphere\"\n dived deep into the ocean.\n\n    in the atlantic abyss\nhe observed many strange fish\n and described 5 new species.\n  none have been seen since.\n\n       for a reason..."

cutscene_objects = {}

function create_cutscene()
    for i, line in ipairs(split(cutscene_text, "\n")) do
        local obj = {text=line, timer=-(i-1)*140}
        add_tf(obj)
        add(cutscene_objects, obj)
    end
end

function display_cutscene()
    for message in all(cutscene_objects) do
        message.timer += 1
        tf_update(message)
        if message.timer > -60 then
            if message.y > -50 then
                message.ddy = -0.08
            elseif message.y > -110 then
                message.ddy = -0.01
            else
                message.ddy = -0.04
            end
        end 
        local y = message.y
        local x = 7+sin(y/40)*3
        print(message.text, x+1, y+1, 4)
        print(message.text, x, y, 7)
        if message.y < -50 then
            fillp(0b1111111111111111.1)
        elseif message.y < -42 then
            fillp(0b1010010110100101.1)
        elseif message.y < -32 then
            fillp(0b0010010010000001.1)
        else
            fillp(0b0000000000000000.1)
        end
        rectfill(0, y, 128, y+5, 1)
    end
    fillp()
    if cutscene_objects[1].timer > 1430 then
        if time()%1 < 0.7 then
            print("❎ continue", 42, -8, 5)
        end
    end
    for i = 1,5 do
        local t = (t()/2%1 - 2 + 1 * i) * 32
        spr(169, t, -40, 2, 2)
        spr(169, t + 16, -40, 2, 2, true)
    end
    for i = 1,5 do
        local t = (t()/3.8%1 - 2 + 1 * i) * 32
        spr(183, 128-t - 16, -34, 2, 1)
        spr(183, 128-t - 32, -34, 2, 1, true)
    end
    if btnp(4) or btnp(5) then
        cutscene_on = false
        music(1)
    end
end