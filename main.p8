

function _init()
    poke(0x5f5c, 0xff) --no button repeat--
    poke(0x5f5d, 0xff) --no button repeat--
    pal(4, 129, 1) -- add blues to pallette
    pal(5, 140, 1)

    environment = {
        drag = 0.95,
    }

    player = player_create()

    level_height = 112
    level_speed = 2/3
    beat_counter = 0
    beat_time = 6
    in_beat_ctr = 0

    pillars = {}
    player_bullets = {}
    enemy_bullets = {}
    enemies = {}

    particles = {}
    for i=1,20 do
        particles[i] = {rnd(level_height), rnd(127)}
    end
end


function _update60()
    --update player--
    player_update()

    --update level generator--
    in_beat_ctr+=1
    if in_beat_ctr > beat_time then
        in_beat_ctr = 0
        beat_counter += 1
        if beat_counter % 23 == 0 then -- every 2.3 seconds
            -- pillar_spawn(32 + rnd(80), 24 + rnd(16))
            pillar_spawn(31+rnd(30), 24)
        elseif beat_counter % 35 == 0 then
            bubblefish_spawn(16+rnd(88))
        elseif beat_counter % 200 == 0 then
            bubblefish_spawn(46+rnd(8))
            bubblefish_spawn(76+rnd(8))
        end
    end

    local idx_to_remove = {}
    for i, enemy in pairs(enemies) do
        enemy.update_func(enemy)
        if enemy.hp < 1 then
            enemy.dead = true
            enemy.die_func(enemy)
        end
        if enemy.dead then
            add(idx_to_remove, i)
        end
    end
    for i in all(idx_to_remove) do
        deli(enemies, i)
    end

    enemy_bullets_update()

    pillars_update()

    for k, particle in pairs(particles) do
        if (k > 13) then 
            particle[1] -= level_speed * 0.8
        elseif (k > 5) then
            particle[1] -= level_speed * 0.6
        else
            particle[1] -= level_speed * 0.4
        end
        if particle[1] < -1 then
            particle[1] = 128
            particle[2] = rnd(level_height)
        end
    end
end


function _draw()
    cls(4)
    rectfill(0, 0, 127, 16, 1)
    for i=0,127,8 do
        spr(80, i, 16, 1, 3)
    end

    -- draw particles --
    for particle in all(particles) do
        pset(particle[1], particle[2], 5)
    end

    for pillar in all(pillars) do
        pillar_draw(pillar)
    end
    for enemy in all(enemies) do
        enemy.draw_func(enemy)
    end
    for bullet in all(player_bullets) do
        local len = 12*(4 - bullet.dx)
        line(bullet.x, bullet.y, bullet.x-len*bullet.dx, bullet.y-len*bullet.dy, 7)
        circfill(bullet.x-10, bullet.y, bullet.dx)
        spr(4, bullet.x-8, bullet.y-4, 2, 1)
    end
    spr(1, player.x-12, player.y-7, 3, 2)
    for bullet in all(enemy_bullets) do
        spr(23, bullet.x-4, bullet.y-4)
    end
    rectfill(0, level_height, 127, 127, 1)
    line(0, level_height, 128, level_height, 7)
    local lives = ""
    for i=1,player.hp do
        lives = lives.."♥"
    end
    local torpedoes = ""
    for i=1,player.shots_left do
        torpedoes = torpedoes.."|"
    end
    print(lives.."  "..torpedoes, 2, level_height+3)

    -- print("plr:"..#pillars.." enm:"..#enemies.." pb:"..#player_bullets.." eb:"..#enemy_bullets, 38, level_height + 3)

    --debug--
    -- pset(player.x, player.y, 11)
    -- rect(player.x-player.x_half_size, player.y-player.y_half_size, player.x+player.x_half_size, player.y + player.y_half_size, 11)

    if game_over then
        print("game over", 50, 60)
    end
end
