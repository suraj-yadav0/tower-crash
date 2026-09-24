.pragma library

function spawnParticles(particles, units, outerRadius, innerRadius, x, y, count, color, speedMultiplier) {
    var mult = speedMultiplier || 1.0;
    var midR = (outerRadius + innerRadius) / 2.0;
    for (var p = 0; p < count; p++) {
        var angle = Math.random() * Math.PI * 2.0;
        var speed = (units.gu(2) + Math.random() * units.gu(10)) * mult;
        var rSpread = (Math.random() - 0.5) * (outerRadius - innerRadius);
        particles.push({
            x: x + Math.cos(angle) * rSpread,
            y: y,
            z: midR + Math.sin(angle) * rSpread,
            vx: Math.cos(angle) * speed,
            vy: -Math.random() * units.gu(16) * mult,
            vz: Math.sin(angle) * speed,
            color: color,
            alpha: 1.0,
            size: units.gu(0.4 + Math.random() * 0.6)
        });
    }
}

function spawnBounceDust(particles, units, outerRadius, innerRadius, y, color1, color2) {
    var midR = (outerRadius + innerRadius) / 2.0;
    var count = 4;
    for (var p = 0; p < count; p++) {
        var angle = Math.random() * Math.PI * 2.0;
        var speed = units.gu(4.0) + Math.random() * units.gu(8.0);
        particles.push({
            x: Math.cos(angle) * units.gu(0.9),
            y: y,
            z: midR + Math.sin(angle) * units.gu(0.9),
            vx: Math.cos(angle) * speed,
            vy: -units.gu(1.5) - Math.random() * units.gu(4.0),
            vz: Math.sin(angle) * speed,
            color: (Math.random() < 0.6) ? color1 : color2,
            alpha: 0.85,
            size: units.gu(0.35 + Math.random() * 0.4)
        });
    }
}

function spawnShatterDebris(particles, units, outerRadius, innerRadius, ringY, isGoal, isGrand, theme, isSuper) {
    var midR = (outerRadius + innerRadius) / 2.0;
    var topClr = isGoal ? (isGrand ? "#FFD700" : (theme.goalTop || "#E8C872")) : (isSuper ? theme.topSafe : theme.topSafe);
    var edgeClr = isGoal ? (isGrand ? "#B8860B" : (theme.goalSide || "#B09242")) : (isSuper ? theme.sideSafe : theme.sideSafe);

    particles.push({
        kind: "shockwave",
        x: 0,
        y: ringY,
        z: midR,
        vx: 0,
        vy: 0,
        vz: 0,
        radius: units.gu(2.0),
        maxRadius: outerRadius * 1.6,
        speed: units.gu(42.0),
        thickness: units.gu(0.65),
        color: isGoal ? (isGrand ? "#FFD700" : "#E8C872") : (isSuper ? "#FF793F" : theme.topSafe),
        alpha: 0.95,
        decay: 3.2
    });

    var chunkCount = isGrand ? 5 : 3;
    for (var c = 0; c < chunkCount; c++) {
        var chunkAngle = (c / chunkCount) * Math.PI * 2.0 + (Math.random() - 0.5) * 0.35;
        var chunkR = midR + (Math.random() - 0.5) * units.gu(2.2);
        var radialSpeed = (units.gu(9) + Math.random() * units.gu(12)) * (isSuper ? 1.4 : 1.0);
        var cw = units.gu(2.6 + Math.random() * 1.6);
        var ch = units.gu(1.8 + Math.random() * 1.0);

        particles.push({
            kind: "chunk",
            x: Math.cos(chunkAngle) * chunkR,
            y: ringY,
            z: Math.sin(chunkAngle) * chunkR,
            vx: Math.cos(chunkAngle) * radialSpeed,
            vy: -units.gu(4 + Math.random() * 8) * (isSuper ? 1.3 : 1.0),
            vz: Math.sin(chunkAngle) * radialSpeed,
            rotX: Math.random() * Math.PI * 2.0,
            rotY: Math.random() * Math.PI * 2.0,
            rotZ: Math.random() * Math.PI * 2.0,
            vrotX: (Math.random() - 0.5) * 8.0,
            vrotY: (Math.random() - 0.5) * 9.0,
            vrotZ: (Math.random() - 0.5) * 8.0,
            width: cw,
            height: ch,
            depth: units.gu(1.0),
            topColor: topClr,
            edgeColor: edgeClr,
            specular: isGoal,
            alpha: 1.0,
            decay: 0.9
        });
    }

    var shardCount = isGrand ? 8 : 5;
    for (var s = 0; s < shardCount; s++) {
        var shardAngle = Math.random() * Math.PI * 2.0;
        var shardR = innerRadius + Math.random() * (outerRadius - innerRadius);
        var shardSpeed = (units.gu(11) + Math.random() * units.gu(15)) * (isSuper ? 1.4 : 1.0);
        var sw = units.gu(1.4 + Math.random() * 0.9);
        var sh = units.gu(1.1 + Math.random() * 0.7);

        particles.push({
            kind: "shard",
            x: Math.cos(shardAngle) * shardR,
            y: ringY,
            z: Math.sin(shardAngle) * shardR,
            vx: Math.cos(shardAngle) * shardSpeed,
            vy: -units.gu(5 + Math.random() * 9),
            vz: Math.sin(shardAngle) * shardSpeed,
            rotX: Math.random() * Math.PI * 2.0,
            rotY: Math.random() * Math.PI * 2.0,
            rotZ: Math.random() * Math.PI * 2.0,
            vrotX: (Math.random() - 0.5) * 14.0,
            vrotY: (Math.random() - 0.5) * 16.0,
            vrotZ: (Math.random() - 0.5) * 14.0,
            width: sw,
            height: sh,
            depth: units.gu(0.6),
            topColor: topClr,
            edgeColor: edgeClr,
            specular: isGoal,
            alpha: 1.0,
            decay: 1.2
        });
    }

    var sparkCount = isGrand ? 16 : 10;
    for (var sp = 0; sp < sparkCount; sp++) {
        var spAngle = Math.random() * Math.PI * 2.0;
        var spSpeed = units.gu(14) + Math.random() * units.gu(18);
        particles.push({
            kind: "spark",
            x: Math.cos(spAngle) * midR,
            y: ringY,
            z: Math.sin(spAngle) * midR,
            vx: Math.cos(spAngle) * spSpeed,
            vy: -units.gu(8 + Math.random() * 14),
            vz: Math.sin(spAngle) * spSpeed,
            size: units.gu(0.35 + Math.random() * 0.3),
            color: isGoal ? "#FFFFFF" : (isSuper ? "#FFEAA7" : topClr),
            alpha: 1.0,
            decay: 2.2
        });
    }

    for (var d = 0; d < 6; d++) {
        var dustAngle = Math.random() * Math.PI * 2.0;
        var dustR = midR + (Math.random() - 0.5) * units.gu(2.4);
        particles.push({
            kind: "dust",
            x: Math.cos(dustAngle) * dustR,
            y: ringY,
            z: Math.sin(dustAngle) * dustR,
            vx: Math.cos(dustAngle) * units.gu(3 + Math.random() * 4),
            vy: -units.gu(1.5 + Math.random() * 3),
            vz: Math.sin(dustAngle) * units.gu(3 + Math.random() * 4),
            size: units.gu(0.8),
            targetSize: units.gu(2.2 + Math.random() * 1.0),
            color: topClr,
            alpha: 0.65,
            decay: 1.6
        });
    }

    while (particles.length > 20) {
        particles.shift();
    }
}

function spawnSegmentShatter(particles, units, outerRadius, innerRadius, ringY, angle, topClr, edgeClr) {
    var midR = (outerRadius + innerRadius) / 2.0;
    for (var s = 0; s < 6; s++) {
        var shardAngle = angle + (Math.random() - 0.5) * 0.45;
        var radialSpeed = units.gu(8) + Math.random() * units.gu(11);
        var sw = units.gu(1.5 + Math.random() * 0.8);
        var sh = units.gu(1.2 + Math.random() * 0.7);
        particles.push({
            kind: "shard",
            x: Math.cos(shardAngle) * midR,
            y: ringY,
            z: Math.sin(shardAngle) * midR,
            vx: Math.cos(shardAngle) * radialSpeed,
            vy: -units.gu(4 + Math.random() * 6),
            vz: Math.sin(shardAngle) * radialSpeed,
            rotX: Math.random() * Math.PI * 2.0,
            rotY: Math.random() * Math.PI * 2.0,
            rotZ: Math.random() * Math.PI * 2.0,
            vrotX: (Math.random() - 0.5) * 12.0,
            vrotY: (Math.random() - 0.5) * 14.0,
            vrotZ: (Math.random() - 0.5) * 12.0,
            width: sw,
            height: sh,
            depth: units.gu(0.6),
            topColor: topClr,
            edgeColor: edgeClr,
            specular: false,
            alpha: 1.0,
            decay: 1.4
        });
    }
    while (particles.length > 20) {
        particles.shift();
    }
}

function updateParticles(particles, dt, gravity, poleRadius, units) {
    for (var p = particles.length - 1; p >= 0; p--) {
        var pt = particles[p];
        pt.x += (pt.vx || 0) * dt;
        pt.y += (pt.vy || 0) * dt;
        pt.z += (pt.vz || 0) * dt;

        if (pt.kind === "shockwave") {
            pt.radius += (pt.speed || units.gu(30.0)) * dt;
        } else if (pt.kind === "dust") {
            if (pt.size < pt.targetSize) {
                pt.size = Math.min(pt.targetSize, pt.size + dt * units.gu(4.0));
            }
        } else {
            pt.vy += gravity * 0.7 * dt;
            pt.vx *= Math.pow(0.86, dt);
            pt.vz *= Math.pow(0.86, dt);

            var distFromPole = Math.sqrt(pt.x * pt.x + pt.z * pt.z);
            var pThickness = (pt.kind === "chunk") ? (pt.depth || units.gu(1.0)) * 0.5 :
                             ((pt.kind === "shard") ? (pt.depth || units.gu(0.6)) * 0.5 : (pt.size || units.gu(0.35)) * 0.5);
            var minDistance = poleRadius + pThickness;

            if (distFromPole < minDistance) {
                var nx = distFromPole > 0.0001 ? (pt.x / distFromPole) : 1.0;
                var nz = distFromPole > 0.0001 ? (pt.z / distFromPole) : 0.0;

                pt.x = nx * minDistance;
                pt.z = nz * minDistance;

                var vRadial = (pt.vx || 0) * nx + (pt.vz || 0) * nz;
                if (vRadial < 0) {
                    var tx = (pt.vx || 0) - nx * vRadial;
                    var tz = (pt.vz || 0) - nz * vRadial;

                    var restitution = (pt.kind === "chunk") ? 0.35 : 0.48;
                    var bounceV = -vRadial * restitution;

                    var rollFriction = 0.94;
                    pt.vx = tx * rollFriction + nx * bounceV;
                    pt.vz = tz * rollFriction + nz * bounceV;
                    pt.vy *= 0.94;

                    var tangentSpeed = tx * (-nz) + tz * nx;
                    if (pt.vrotY !== undefined) {
                        pt.vrotY = pt.vrotY * 0.8 + (tangentSpeed / minDistance) * 3.5;
                    }
                    if (pt.vrotZ !== undefined) {
                        pt.vrotZ = pt.vrotZ * 0.85 + tangentSpeed * 1.8;
                    }
                }
            }

            if (pt.vrotX) pt.rotX = (pt.rotX || 0) + pt.vrotX * dt;
            if (pt.vrotY) pt.rotY = (pt.rotY || 0) + pt.vrotY * dt;
            if (pt.vrotZ) pt.rotZ = (pt.rotZ || 0) + pt.vrotZ * dt;
        }

        pt.alpha -= dt * (pt.decay || 1.6);
        if (pt.alpha <= 0.01 || (pt.kind === "shockwave" && pt.radius >= pt.maxRadius)) {
            particles.splice(p, 1);
        }
    }

    while (particles.length > 20) {
        particles.shift();
    }
}
