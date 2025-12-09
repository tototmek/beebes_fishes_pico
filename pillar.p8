
function pillar_spawn(gap_y, gap_width)
    local pillar = {collision = true,}
    add_tf(pillar, 132, gap_y - gap_width - 64)
    add_collider(pillar, 4, 64)
    add(pillars, pillar)
    pillar = {collision = true,}
    add_tf(pillar, 132, gap_y + gap_width + 64)
    add_collider(pillar, 4, 64)
    add(pillars, pillar)
end

function pillar_draw(pillar)
    spr(32, pillar.x-4, pillar.y-64)
    for i=1,14 do
        spr(48, pillar.x-4, pillar.y-64+i*8)
    end
    spr(32, pillar.x-4, pillar.y+56, 1, 1, false, true)
end

function pillars_update() 
    local i = #pillars
    for i=#pillars, 1, -1 do
        local pillar = pillars[i]
        pillar.dx = -level_speed
        tf_update(pillar)
        if pillar.x < player.x - 4 then
            pillar.collision = false --prevents hitting a pillar from the back
        end
        if pillar.x < -4 then
            deli(pillars, i)
        elseif pillar.collision and check_collision(player, pillar) then
            player_get_hit()
        end
    end
end