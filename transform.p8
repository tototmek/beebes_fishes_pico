function add_tf(tab, x, y, dx, dy, ddx, ddy)
    -- tab.x = x or 0
    -- tab.y = y or 0
    -- tab.dx = dx or 0
    -- tab.dy = dy or 0
    -- tab.ddx = ddx or 0
    -- tab.ddy = ddy or 0
    -- tab.drag = environment.drag
     {
        x = x or 0, y = y or 0,
        dx = dx or 0, dy = dy or 0,
        ddx = ddx or 0, ddy = ddy or 0,
        drag = environment.drag,
    }
end

function tf_update(tf)
    tf.dx += tf.ddx
    tf.dy += tf.ddy
    tf.x += tf.dx
    tf.y += tf.dy
    tf.dx *= tf.drag
    tf.dy *= tf.drag
end

function tf_spring_to(tf, x, y, springiness)
    if (x) tf.ddx = springiness * (x - tf.x) 
    if (y) tf.ddy = springiness * (y - tf.y) 
end
