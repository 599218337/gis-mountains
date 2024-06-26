// 于2023/12/14摘自于 https://www.shadertoy.com/view/4dt3zn 的像素着色器片段

/*

	Raymarched Reflections
	----------------------

	A very basic demonstration of raymarching a distance field with reflections 
	and reasonably passable shadows. Definitely not cutting edge, but hopefully, 
	interesting to anyone who isn't quite familiar with the process.

	Reflections are pretty easy: Raymarch to the hit point, then obtain the color 
	at that point. Continue on from the hit point in the direction of the reflected 
	ray until you reach a new hit point. Obtain the color at the new point, then
	add a portion of it to your original color. Repeat the process.

	Unfortunately, the extra work can slow things down, especially when you apply
	shadows, which is probably why you don't see too many shadowed,	reflected 
	examples. However, for relatively simple distance fields, it's pretty doable.

	It was tempting to do this up, but I figured a simpler example would be more
	helpful. Take away the rambling comments, and there isn't a great deal of code.
	I'll post a more sophisticated one later.

    // Reasonably simple examples featuring reflection:

    To the road of ribbon - XT95
    https://www.shadertoy.com/view/MsfGzr

    704.2 - PauloFalcao
    https://www.shadertoy.com/view/Xdj3Dt

    // Reflections and refraction. Really cool.
    Glass Polyhedron - Nrx
    https://www.shadertoy.com/view/4slSzj

*/

#define FAR 30.

// Distance function: This one is pretty simple. I chose rounded
// spherical boxes, because they're cheap and they display the 
// reflections reasonably well.
float map(vec3 p) {

    // Positioning the rounded cubes a little off center, in order
    // to break up the space a little.
    //
    // "floor(p)" represents a unique number (ID) for each cube 
    // (based on its unique position). Take that number and produce 
    // a randomized 3D offset, then add it to it's regular position. 
    // Simple.
    float n = sin(dot(floor(p), vec3(27, 113, 57)));
    vec3 rnd = fract(vec3(2097152, 262144, 32768) * n) * .16 - .08;

    // Repeat factor. If irregularity isn't your thing, you can get 
    // rid of "rnd" to line things up again.
    p = fract(p + rnd) - .5;

    // Rounded spherical boxes. The following is made up, but kind of
    // makes sense. Box, minus a bit of sphericalness, gives you a 
    // rounded box. By the way, if we're splitting hairs, this is 
    // technically a bound rather than a distance function, but it 
    // works roughly the same way.
    p = abs(p);
    return max(p.x, max(p.y, p.z)) - 0.25 + dot(p, p) * 0.5;

    //return length(p) - 0.225; // Just spheres.
}

// Standard raymarching routine.
float trace(vec3 ro, vec3 rd) {

    float t = 0., d;

    for(int i = 0; i < 96; i++) {

        d = map(ro + rd * t);

        // Using the hacky "abs," trick, for more accuracy. 
        if(abs(d) < .001 || t > FAR)
            break;

        t += d * .75;  // Using more accuracy, in the first pass.
    }

    return t;
}

// Second pass, which is the first, and only, reflected bounce. 
// Virtually the same as above, but with fewer iterations and less 
// accuracy.
//
// The reason for a second, virtually identical equation is that 
// raymarching is usually a pretty expensive exercise, so since the 
// reflected ray doesn't require as much detail, you can relax things 
// a bit - in the hope of speeding things up a little.
float traceRef(vec3 ro, vec3 rd) {

    float t = 0., d;

    for(int i = 0; i < 48; i++) {

        d = map(ro + rd * t);

        if(abs(d) < .002 || t > FAR)
            break;

        t += d;
    }

    return t;
}

// Cheap shadows are hard. In fact, I'd almost say, shadowing repeat objects - in a setting like 
// this - with limited iterations is impossible... However, I'd be very grateful if someone could 
// prove me wrong. :)
float softShadow(vec3 ro, vec3 lp, float k) {

    // More would be nicer. More is always nicer, but not really affordable... Not on my slow test 
    // machine, anyway.
    const int maxIterationsShad = 24;

    vec3 rd = lp - ro; // Unnormalized direction ray.

    float shade = 1.;
    float dist = .002;
    float end = max(length(rd), .001);
    float stepDist = end / float(maxIterationsShad);

    rd /= end;

    // Max shadow iterations - More iterations make nicer shadows, but slow things down. Obviously, 
    // the lowest number to give a decent shadow is the best one to choose. 
    for(int i = 0; i < maxIterationsShad; i++) {

        float h = map(ro + rd * dist);
        //shade = min(shade, k*h/dist);
        shade = min(shade, smoothstep(0., 1., k * h / dist)); // Subtle difference. Thanks to IQ for this tidbit.
        // So many options here, and none are perfect: dist += min(h, .2), dist += clamp(h, .01, .2), 
        // clamp(h, .02, stepDist*2.), etc.
        dist += clamp(h, .02, .25);

        // Early exits from accumulative distance function calls tend to be a good thing.
        if(h < 0. || dist > end)
            break; 
        //if (h<.001 || dist > end) break; // If you're prepared to put up with more artifacts.
    }

    // I've added 0.5 to the final shade value, which lightens the shadow a bit. It's a preference thing. 
    // Really dark shadows look too brutal to me.
    return min(max(shade, 0.) + .25, 1.);
}

// Standard normal function. It's not as fast as the tetrahedral calculation, but more symmetrical.
vec3 getNormal(in vec3 p) {
    const vec2 e = vec2(.001, 0);
    return normalize(vec3(map(p + e.xyy) - map(p - e.xyy), map(p + e.yxy) - map(p - e.yxy), map(p + e.yyx) - map(p - e.yyx)));
}

/*
// Tetrahedral normal, to save a couple of "map" calls. Courtesy of IQ.
vec3 getNormal( in vec3 p ){

    // Note the slightly increased sampling distance, to alleviate
    // artifacts due to hit point inaccuracies.
    vec2 e = vec2(.0015, -.0015); 
    return normalize(
        e.xyy * map(p + e.xyy) + 
        e.yyx * map(p + e.yyx) + 
        e.yxy * map(p + e.yxy) + 
        e.xxx * map(p + e.xxx));
}
*/

// Alternating the objects' colors in a 3D checkered arrangement.
// You could just return a single color, if you wanted, but I
// thought I'd mix things up a bit.
//
// Color scheme mildly influenced by: Sound Experiment 3 - aiekick
// https://www.shadertoy.com/view/Ml2XWt
vec3 getObjectColor(vec3 p) {

    // "floor(p)" is analogous to a unique ID - based on position.
    vec3 ip = floor(p);

    // Unique random cell number.
    float rnd = fract(sin(dot(ip, vec3(27.17, 112.61, 57.53))) * 43758.5453);

    // Color up the objects in a cubic checkered arrangement using a subtle version
    // of IQ's palette formula.
    vec3 col = (fract(dot(ip, vec3(.5))) > .001) ? .5 + .45 * cos(mix(3., 4., rnd) + vec3(.9, .45, 1.5)) //vec3(.6, .3, 1.)
    : vec3(.7 + .3 * rnd);

    // Reverse the RGB channels on some of the objects, for a bit of variance.
    if(fract(rnd * 1183.5437 + .42) > .65)
        col = col.zyx;

    return col;

}

// Using the hit point, unit direction ray, etc, to color the 
// scene. Diffuse, specular, falloff, etc. It's all pretty 
// standard stuff.
vec3 doColor(in vec3 sp, in vec3 rd, in vec3 sn, in vec3 lp, float t) {

    vec3 ld = lp - sp; // Light direction vector.
    float lDist = max(length(ld), .001); // Light to surface distance.
    ld /= lDist; // Normalizing the light vector.

    // Attenuating the light, based on distance.
    float atten = 1. / (1. + lDist * .2 + lDist * lDist * .1);

    // Standard diffuse term.
    float diff = max(dot(sn, ld), 0.);
    // Standard specualr term.
    float spec = pow(max(dot(reflect(-ld, sn), -rd), 0.), 8.);

    // Coloring the object. You could set it to a single color, to
    // make things simpler, if you wanted.
    vec3 objCol = getObjectColor(sp);

    // Combining the above terms to produce the final scene color.
    vec3 sceneCol = (objCol * (diff + .15) + vec3(1., .6, .2) * spec * 2.) * atten;

    // Fog factor -- based on the distance from the camera.
    float fogF = smoothstep(0., .95, t / FAR);
    //
    // Applying the background fog. Just black, in this case, but you could
    // render sky, etc, as well.
    sceneCol = mix(sceneCol, vec3(0), fogF); 

    // Return the color. Performed once every pass... of which there are
    // only two in this particular instance.
    return sceneCol;

}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    // Screen coordinates.
    vec2 uv = (fragCoord.xy - iResolution.xy * .5) / iResolution.y;

    // Unit direction ray.
    vec3 rd = normalize(vec3(uv, 1));

    // Some cheap camera movement, for a bit of a look around. I use this far
    // too often. I'm even beginning to bore myself at this point. :)
    float cs = cos(iTime * .25), si = sin(iTime * .25);
    rd.xy = mat2(cs, si, -si, cs) * rd.xy;
    rd.xz = mat2(cs, si, -si, cs) * rd.xz;

    // Ray origin: Doubling as the surface position, in this particular example.
    // I hope that doesn't confuse anyone.
    vec3 ro = vec3(0, 0, iTime * 1.5);

    // Light position. Set in the vicinity the ray origin.
    vec3 lp = ro + vec3(0, 1, -.5);

    // FIRST PASS.

    float t = trace(ro, rd);

    // Advancing the ray origin, "ro," to the new hit point.
    ro += rd * t;

    // Retrieving the normal at the hit point.
    vec3 sn = getNormal(ro);

    // Retrieving the color at the hit point, which is now "ro." I agree, reusing 
    // the ray origin to describe the surface hit point is kind of confusing. The reason 
    // we do it is because the reflective ray will begin from the hit point in the 
    // direction of the reflected ray. Thus the new ray origin will be the hit point. 
    // See "traceRef" below.
    vec3 sceneColor = doColor(ro, rd, sn, lp, t);

    // Checking to see if the surface is in shadow. Ideally, you'd also check to
    // see if the reflected surface is in shadow. However, shadows are expensive, so
    // it's only performed on the first pass. If you pause and check the reflections,
    // you'll see that they're not shadowed. OMG! Better call the shadow police. :)
    float sh = softShadow(ro + sn * .0015, lp, 16.);

    // SECOND PASS - REFLECTED RAY

    // Standard reflected ray, which is just a reflection of the unit
    // direction ray off of the intersected surface. You use the normal
    // at the surface point to do that. Hopefully, it's common sense.
    rd = reflect(rd, sn);

    // The reflected pass begins where the first ray ended, which is the suface
    // hit point, or in a few cases, beyond the far plane. By the way, for the sake
    // of simplicity, we'll perform a reflective pass for non hit points too. Kind
    // of wasteful, but not really noticeable. The direction of the new ray will
    // obviously be in the direction of the reflected ray. See just above.
    //
    // To anyone who's new to this, don't forgot to nudge the ray off of the 
    // initial surface point. Otherwise, you'll intersect with the surface
    // you've just hit. After years of doing this, I still forget on occasion.
    t = traceRef(ro + sn * .003, rd);

    // Advancing the ray origin, "ro," to the new reflected hit point.
    ro += rd * t;

    // Retrieving the normal at the reflected hit point.
    sn = getNormal(ro);

    // Coloring the reflected hit point, then adding a portion of it to the final scene color.
    // How much you add, and how you apply it is up to you, but I'm simply adding 35 percent.
    sceneColor += doColor(ro, rd, sn, lp, t) * .35;
    // Other combinations... depending what you're trying to achieve.
    //sceneColor = sceneColor*.7 + doColor(ro, rd, sn, lp, t)*.5;

    // APPLYING SHADOWS
    //
    // Multiply the shadow from the first pass by the final scene color. Ideally, you'd check to
    // see if the reflected point was in shadow, and incorporate that too, but we're cheating to
    // save cycles and skipping it. It's not really noticeable anyway. By the way, ambient
    // occlusion would make it a little nicer, but we're saving cycles and keeping things simple.
    sceneColor *= sh;

    // Clamping the scene color, performing some rough gamma correction (the "sqrt" bit), then 
    // presenting it to the screen.
    fragColor = vec4(sqrt(clamp(sceneColor, 0., 1.)), 1);
}