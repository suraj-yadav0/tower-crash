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

function addFallingBlock(particles, units, outerRadius, innerRadius, ringY, rH, midR, segStart, segMid, topClr, sideClr, isHazard, isGoal, isGrand, isSuper, rotSpeed) {
    var radX = Math.cos(segMid);
    var radZ = Math.sin(segMid);
    var tanX = -Math.sin(segMid);
    var tanZ = Math.cos(segMid);

    var mult = isSuper ? 1.35 : 1.0;
    var blastSpeed = units.gu(7.0 + Math.random() * 5.0) * mult;
    var tanVelocity = (rotSpeed ? rotSpeed * midR * 0.6 : 0) + (Math.random() - 0.5) * units.gu(3.0);
    var downSpeed = units.gu(3.0 + Math.random() * 5.0) * mult;

    particles.push({
        kind: "block",
        x: radX * midR,
        y: ringY + rH * 0.5,
        z: radZ * midR,
        vx: radX * blastSpeed + tanX * tanVelocity,
        vy: downSpeed,
        vz: radZ * blastSpeed + tanZ * tanVelocity,
        rotX: (Math.random() - 0.5) * 0.25,
        rotY: (Math.random() - 0.5) * 0.25,
        rotZ: (Math.random() - 0.5) * 0.25,
        vrotX: (Math.random() - 0.5) * 5.5 + (isSuper ? 2.5 : 1.5),
        vrotY: (Math.random() - 0.5) * 4.5,
        vrotZ: (Math.random() - 0.5) * 5.5,
        startAngle: segStart,
        midAngle: segMid,
        segArc: Math.PI / 4.0,
        outerRadius: outerRadius,
        innerRadius: innerRadius,
        height: rH,
        topColor: topClr,
        sideColor: sideClr,
        bottomColor: "rgba(25, 25, 30, 0.85)",
        cutColor: sideClr,
        isHazard: Boolean(isHazard),
        isGoal: Boolean(isGoal),
        isGrand: Boolean(isGrand),
        alpha: 1.0,
        decay: 1.25
    });
}

function spawnShatterDebris(particles, units, outerRadius, innerRadius, ringY, isGoal, isGrand, theme, isSuper, ring, towerAngle, ringHeight) {
    var midR = (outerRadius + innerRadius) / 2.0;
    var rH = ringHeight || units.gu(2.8);
    var ringAngle = (towerAngle || 0.0) + (ring && ring.angleOffset ? ring.angleOffset : 0.0);
    var segments = (ring && ring.segments) ? ring.segments : [0, 0, 0, 0, 0, 0, 0, 0];

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

    for (var s = 0; s < 8; s++) {
        var segType = segments[s];
        if (segType === 1) continue;

        var isHazard = (segType === 2 && !isGoal);
        var topClr = isGoal ? (isGrand ? "#FFF275" : (theme.goalTop || "#E8C872")) : (isHazard ? (theme.topHazard || "#BA3C3C") : (theme.topSafe || "#D99B26"));
        var sideClr = isGoal ? (isGrand ? "#D4AF37" : (theme.goalSide || "#B09242")) : (isHazard ? (theme.sideHazard || "#8E2A2A") : (theme.sideSafe || "#A06B15"));

        var segStart = ringAngle + s * (Math.PI / 4.0);
        var segMid = segStart + (Math.PI / 8.0);
        addFallingBlock(particles, units, outerRadius, innerRadius, ringY, rH, midR, segStart, segMid, topClr, sideClr, isHazard, isGoal, isGrand, isSuper, ring ? ring.rotationSpeed : 0);
    }

    var shardCount = isGrand ? 6 : 4;
    for (var sh = 0; sh < shardCount; sh++) {
        var shardAngle = Math.random() * Math.PI * 2.0;
        var shardR = innerRadius + Math.random() * (outerRadius - innerRadius);
        var shardSpeed = (units.gu(10) + Math.random() * units.gu(13)) * (isSuper ? 1.3 : 1.0);
        particles.push({
            kind: "shard",
            x: Math.cos(shardAngle) * shardR,
            y: ringY,
            z: Math.sin(shardAngle) * shardR,
            vx: Math.cos(shardAngle) * shardSpeed,
            vy: -units.gu(4 + Math.random() * 7),
            vz: Math.sin(shardAngle) * shardSpeed,
            rotX: Math.random() * Math.PI * 2.0,
            rotY: Math.random() * Math.PI * 2.0,
            rotZ: Math.random() * Math.PI * 2.0,
            vrotX: (Math.random() - 0.5) * 12.0,
            vrotY: (Math.random() - 0.5) * 14.0,
            vrotZ: (Math.random() - 0.5) * 12.0,
            width: units.gu(1.3 + Math.random() * 0.7),
            height: units.gu(1.0 + Math.random() * 0.5),
            depth: units.gu(0.5),
            topColor: isGoal ? (isGrand ? "#FFD700" : "#E8C872") : theme.topSafe,
            edgeColor: isGoal ? (isGrand ? "#B8860B" : "#B09242") : theme.sideSafe,
            specular: isGoal,
            alpha: 1.0,
            decay: 1.2
        });
    }

    var sparkCount = isGrand ? 10 : 6;
    for (var sp = 0; sp < sparkCount; sp++) {
        var spAngle = Math.random() * Math.PI * 2.0;
        var spSpeed = units.gu(12) + Math.random() * units.gu(16);
        particles.push({
            kind: "spark",
            x: Math.cos(spAngle) * midR,
            y: ringY,
            z: Math.sin(spAngle) * midR,
            vx: Math.cos(spAngle) * spSpeed,
            vy: -units.gu(6 + Math.random() * 10),
            vz: Math.sin(spAngle) * spSpeed,
            size: units.gu(0.3 + Math.random() * 0.25),
            color: isGoal ? "#FFFFFF" : (isSuper ? "#FFEAA7" : theme.topSafe),
            alpha: 1.0,
            decay: 2.2
        });
    }

    for (var d = 0; d < 4; d++) {
        var dustAngle = Math.random() * Math.PI * 2.0;
        var dustR = midR + (Math.random() - 0.5) * units.gu(2.0);
        particles.push({
            kind: "dust",
            x: Math.cos(dustAngle) * dustR,
            y: ringY,
            z: Math.sin(dustAngle) * dustR,
            vx: Math.cos(dustAngle) * units.gu(3 + Math.random() * 3),
            vy: -units.gu(1.5 + Math.random() * 2.5),
            vz: Math.sin(dustAngle) * units.gu(3 + Math.random() * 3),
            size: units.gu(0.7),
            targetSize: units.gu(1.8 + Math.random() * 0.8),
            color: isGoal ? "#FFF275" : theme.topSafe,
            alpha: 0.60,
            decay: 1.6
        });
    }

    while (particles.length > 32) {
        particles.shift();
    }
}

function spawnSegmentShatter(particles, units, outerRadius, innerRadius, ringY, angle, topClr, edgeClr, segIndex, towerAngle, ring, ringHeight) {
    var midR = (outerRadius + innerRadius) / 2.0;
    var rH = ringHeight || units.gu(2.8);
    var ringAngle = (towerAngle || 0.0) + (ring && ring.angleOffset ? ring.angleOffset : 0.0);
    var segStart = (segIndex !== undefined) ? (ringAngle + segIndex * (Math.PI / 4.0)) : (angle - Math.PI / 8.0);
    var segMid = segStart + (Math.PI / 8.0);

    addFallingBlock(particles, units, outerRadius, innerRadius, ringY, rH, midR, segStart, segMid, topClr, edgeClr, false, false, false, false, ring ? ring.rotationSpeed : 0);

    for (var s = 0; s < 3; s++) {
        var shardAngle = segMid + (Math.random() - 0.5) * 0.45;
        var shardSpeed = units.gu(8) + Math.random() * units.gu(9);
        particles.push({
            kind: "shard",
            x: Math.cos(shardAngle) * midR,
            y: ringY,
            z: Math.sin(shardAngle) * midR,
            vx: Math.cos(shardAngle) * shardSpeed,
            vy: -units.gu(3 + Math.random() * 5),
            vz: Math.sin(shardAngle) * shardSpeed,
            rotX: Math.random() * Math.PI * 2.0,
            rotY: Math.random() * Math.PI * 2.0,
            rotZ: Math.random() * Math.PI * 2.0,
            vrotX: (Math.random() - 0.5) * 12.0,
            vrotY: (Math.random() - 0.5) * 14.0,
            vrotZ: (Math.random() - 0.5) * 12.0,
            width: units.gu(1.3 + Math.random() * 0.6),
            height: units.gu(1.0 + Math.random() * 0.5),
            depth: units.gu(0.5),
            topColor: topClr,
            edgeColor: edgeClr,
            specular: false,
            alpha: 1.0,
            decay: 1.4
        });
    }

    while (particles.length > 32) {
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
        } else if (pt.kind === "block") {
            pt.vy += gravity * 0.85 * dt;
            pt.vx *= Math.pow(0.92, dt);
            pt.vz *= Math.pow(0.92, dt);

            var distFromPole = Math.sqrt(pt.x * pt.x + pt.z * pt.z);
            var blockWidth = (pt.outerRadius - pt.innerRadius) * 0.5;
            var minDistance = poleRadius + blockWidth * 0.55;

            if (distFromPole < minDistance) {
                var nx = distFromPole > 0.0001 ? (pt.x / distFromPole) : 1.0;
                var nz = distFromPole > 0.0001 ? (pt.z / distFromPole) : 0.0;
                pt.x = nx * minDistance;
                pt.z = nz * minDistance;

                var vRad = (pt.vx || 0) * nx + (pt.vz || 0) * nz;
                if (vRad < 0) {
                    var bounceSpeed = -vRad * 0.35;
                    pt.vx = (pt.vx - nx * vRad) * 0.90 + nx * bounceSpeed;
                    pt.vz = (pt.vz - nz * vRad) * 0.90 + nz * bounceSpeed;
                    pt.vy *= 0.92;
                }
            }

            if (pt.vrotX) pt.rotX = (pt.rotX || 0) + pt.vrotX * dt;
            if (pt.vrotY) pt.rotY = (pt.rotY || 0) + pt.vrotY * dt;
            if (pt.vrotZ) pt.rotZ = (pt.rotZ || 0) + pt.vrotZ * dt;
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

    while (particles.length > 32) {
        particles.shift();
    }
}
