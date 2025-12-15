
function pillar_spawn(gap_y, gap_width)
    local pillar = {collision = true,}
    add_tf(pillar, 132, gap_y - gap_width - 72)
    add_collider(pillar, 4, 72)
    add(pillars, pillar)
    pillar = {collision = true,}
    add_tf(pillar, 132, gap_y + gap_width + 72)
    add_collider(pillar, 4, 72)
    add(pillars, pillar)
end

function pillar_draw(pillar)
    map(0, 9, flr(pillar.x-4), pillar.y-72, 3, 18)
end

function pillars_update() 
    for i, pillar in ipairs(pillars) do
        pillar.dx = -level_speed
        tf_update(pillar)
        if pillar.x < player.x - 4 then
            pillar.collision = false --prevents hitting a pillar from the back
        end
        if pillar.x < -20 then
            deli(pillars, i)
        elseif pillar.collision and check_collision(player, pillar) then
            player_get_hit()
        end
    end
end