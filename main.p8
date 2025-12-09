

function _init()
    poke(0x5f5c, 0xff) --no button repeat--
    poke(0x5f5d, 0xff) --no button repeat--

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
    pillar_spawn(32 + rnd(80), 48 + rnd(16))
    bubblefish_spawn(48)
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
            pillar_spawn(32 + rnd(80), 48 + rnd(16))
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


    --update pillars--    TODO: optimize with a circular buffer
    pillars_update()
end


function _draw()
    cls(1)
    for pillar in all(pillars) do
        pillar_draw(pillar)
    end
    for enemy in all(enemies) do
        enemy.draw_func(enemy)
    end
    spr(1, player.tf.x-12, player.tf.y-7, 3, 2)
    for bullet in all(enemy_bullets) do
        spr(23, bullet.tf.x-4, bullet.tf.y-4)
    end
    for bullet in all(player_bullets) do
        spr(4, bullet.tf.x-8, bullet.tf.y-4, 2, 1)
    end
    rectfill(0, level_height, 128, 128, 0)
    line(0, level_height, 128, level_height, 11)
    print("lives: "..player.hp)

    --debug--
    -- pset(player.x, player.y, 11)
    -- rect(player.x-player.w_half, player.y-player.h_half, player.x+player.w_half, player.y + player.h_half, 11)

    if game_over then
        print("GAME OVER")
    end
end
