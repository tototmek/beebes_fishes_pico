
spawn_functions = {
    bubblefish_spawn,
    constellationfish_spawn,
    anglerfish_spawn,
    medusa_spawn,
    nautilus_spawn,
    naked_nautilus_spawn,
    rainbowgar_spawn,
    sailfin_spawn,
    bathysphaera_spawn,
}

function spawners_init(starting_checkpoint)
    spawner_stage = 1 + starting_checkpoint
    printh("Starting from stage "..spawner_stage)
    spawner_current_spr = 0
    spawner_pillar_rate = 0
    pillar_spawner_coroutine = cocreate(pillar_spawner_run)
    spawner_coroutine = cocreate(spawner_run)
end

function pillar_spawner_run()
    while true do
        if spawner_pillar_rate > 0 then
            pillar_spawn(64+sin(t()/5)*24, 22 + rnd(8))
        end
        yield()
        for i=1,3*(16-spawner_pillar_rate)+flr(rnd(2)) do
            yield()
        end
    end
end


function spawner_run()
    for i=1,10 do
        yield()
    end
    -- bubblefish_spawn(63)
    -- medusa_spawn(63)
    for i=1,30 do
        yield()
    end
    while spawner_stage < 7 do
        for i=1,5 do
            spawner_perform_random_sprite()
            spawner_current_spr = i
        end
        spawner_perform_final_sprite()
        spawner_stage+=1
        spawner_current_spr = 0
        if spawner_stage-1 > dget(1) then
            dset(1, spawner_stage-1)
            printh("Checkpoint unlocked")
        end
    end
    while true do
        spawner_perform_random_sprite()
    end
end

function spawner_perform_random_sprite()
    spawner_perform_sprite(192+(spawner_stage-1)*8+flr(rnd(6)))
end

function spawner_perform_final_sprite()
    spawner_perform_sprite(199+(spawner_stage-1)*8)
    while #enemies > 0 do
        yield()
    end
end

function spawner_perform_sprite(spr_id)
    printh("stage "..spawner_stage)
    printh("Spawner performing sprite "..spr_id)
    local spr_x, spr_y = (spr_id % 16) * 8, (spr_id \ 16) * 8
    spawner_pillar_rate = sget(spr_x, spr_y)
    step_wait_time = sget(spr_x+1, spr_y)
    for fx = 0,7 do
        for fy = 1,7 do
            local fish_id = sget(spr_x+fx, spr_y+fy)
            if fish_id > 0 then
                spawn_functions[fish_id](24+11.43*fy)
            end
        end
        for i=1,9 do
            yield()
        end
    end
    for i=1,1+4*step_wait_time do
        yield()
    end
end


function spawner_progress_bar_print()
    local seglen = 12
    rect(28, 2, 100, 3, 5)
    line(29, 3, 99, 3, 4)
    local playerpos = 28+(spawner_stage-1)*seglen+spawner_current_spr*2.3
    line(29, 3, playerpos, 3, 5)
    for i = 1,6 do
        if i < spawner_stage then --stage cleared
            spr(166, 24+i*seglen, 0)
        else --stage yet to clear
            spr(167, 24+i*seglen, 0)
        end
    end
    spr(168, playerpos - 3, 0)
end