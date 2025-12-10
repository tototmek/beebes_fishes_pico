function add_tf(tab, x, y, dx, dy, ddx, ddy)
    tab.x = x or 0
    tab.y = y or 0
    tab.dx = dx or 0
    tab.dy = dy or 0
    tab.ddx = ddx or 0
    tab.ddy = ddy or 0
    tab.drag = environment.drag
end

function tf_update(tf)
    tf.dx += tf.ddx
    tf.dy += tf.ddy
    tf.x += tf.dx
    tf.y += tf.dy
    tf.dx *= tf.drag
    tf.dy *= tf.drag
end

function tf_spring_to(tf, x, y, springiness, springiness_y)
    if (x) tf.ddx = springiness * (x - tf.x) 
    if (y) tf.ddy = (springiness_y or springiness) * (y - tf.y) 
end

function add_collider(tab, x_half_size, y_half_size)
    tab.x_half_size = x_half_size or 0
    tab.y_half_size = y_half_size or 0
end

function check_collision(a, b, range)
    local r = range or 0
    local x_offset = a.x_half_size + b.x_half_size + r
    local y_offset = a.y_half_size + b.y_half_size + r
    return
        (a.x > b.x - x_offset)
        and
        (a.x < b.x + x_offset)
        and
        (a.y > b.y - y_offset)
        and
        (a.y < b.y + y_offset)
end