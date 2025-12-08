function bubblefish_spawn(y)
    local enemy = {
        hp = 1, dead = false,
        x = 136, y = y,
        dx = 0, ddx = 0,
        target_x = 104, target_y = y,
        draw_x = 136,
        atk_func = bubblefish_atk,
        die_func = bubblefish_die,
        update_func = bubblefish_update,
        draw_func = bubblefish_draw,
        atk_rate = 15,
        atk_ctr = 0

    }
    add(enemies, enemy)
end

function bubblefish_atk(bf)
    if (bf.atk_ctr < 5) bubblefish_shoot(bf)
    if (bf.atk_ctr == 5) bf.target_x = 148
    if (bf.atk_ctr > 5) bf.dead = true 
end

function bubblefish_die(bf)
end

function bubblefish_update(bf)
    bf.ddx = 0.001 * (bf.target_x - bf.x)
    bf.dx += bf.ddx
    bf.x += bf.dx
    bf.dx *= player.drag
    bf.y = bf.target_y + sin(time()/8) * 8
    bf.draw_x = bf.x + cos(2137+time()/9) * 6
end

function bubblefish_draw(bf) 
    spr(7, flr(bf.draw_x-4), flr(bf.y-4))
end

function bubblefish_shoot(bf)
end