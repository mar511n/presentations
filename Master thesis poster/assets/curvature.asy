// asy -f png -render 5 curvature.asy
// Parallel transport on the unit sphere (correct Levi–Civita transport),
// visualized directly in 3D.

import three;
size(12cm);
currentprojection=perspective(4,6,5);
currentlight.background = rgb(1,1,1);
defaultpen(fontsize(18));

pen gridpen  = gray(0.3)+linewidth(2.0);
pen path1pen = red+linewidth(3.0);
pen path2pen = blue+linewidth(3.0);
pen ptpen    = black+linewidth(8);
pen vec1col  = orange;
pen vec2col  = purple;
pen sphpen   = gray(0.85)+opacity(0.55);

// --- Sphere parametrization (longitude u, latitude v) ---
// r(u,v) = (cos v cos u, cos v sin u, sin v)
triple S(real u, real v)
{
	return (cos(v)*cos(u), cos(v)*sin(u), sin(v));
}

triple Su(real u, real v)
{
	return (-cos(v)*sin(u), cos(v)*cos(u), 0);
}

triple Sv(real u, real v)
{
	return (-sin(v)*cos(u), -sin(v)*sin(u), cos(v));
}

// --- 3D grid curves (u=const or v=const) ---
path3 lineU(real uConst, real v0, real v1, int n=120)
{
  path3 Q = S(uConst, v0);
  for(int i=1; i<=n; ++i) {
    real t = i/(real)n;
    real v = v0 + (v1-v0)*t;
    Q = Q -- S(uConst, v);
  }
  return Q;
}

path3 lineV(real vConst, real u0, real u1, int n=120)
{
  path3 Q = S(u0, vConst);
  for(int i=1; i<=n; ++i) {
    real t = i/(real)n;
    real u = u0 + (u1-u0)*t;
    Q = Q -- S(u, vConst);
  }
  return Q;
}

void drawGrid(real u0, real u1, real v0, real v1, real du, real dv)
{
  for(real u=u0; u<=u1+1e-3; u+=du)
    draw(lineU(u,v0,v1), gridpen);
  for(real v=v0; v<=v1+1e-3; v+=dv)
    draw(lineV(v,u0,u1), gridpen);
}

// --- Draw a transported tangent vector (3D) ---
void drawVector(pair uv, triple v, pen p, real L=0.2)
{
  triple r = S(uv.x, uv.y);
  triple w = v;
  if(length(w) < 1e-12) return;
  w = (L/length(w))*w;

  draw(r -- (r + 0.8*w), p+linewidth(3.0));
  draw(r -- (r + w), p+linewidth(1.0), Arrow3);
}
void drawVector3D(triple r, triple v, pen p, real L=0.2)
{
  triple w = v;
  if(length(w) < 1e-12) return;
  w = (L/length(w))*w;

  draw(r -- (r + 0.7*w), p+linewidth(3.0));
  draw(r -- (r + w), p+linewidth(1.0), Arrow3);
}

// --- Levi–Civita parallel transport on the unit sphere ---
// For a curve r(t) on the unit sphere, ∇_{r'} v = 0 is equivalent to:
//   (d/dt)v is purely normal  =>  v' = -(v·r') r
// This keeps v tangent and yields correct holonomy.
triple vprime(triple r, triple rdot, triple v)
{
	return -dot(v, rdot)*r;
}

pair uvlerp(pair a, pair b, real t)
{
	return (1-t)*a + t*b;
}

triple rOf(pair uv) { return S(uv.x, uv.y); }
triple rdotOf(pair uv, pair uv0, pair uv1)
{
	real up = uv1.x - uv0.x;
	real vp = uv1.y - uv0.y;
	return Su(uv.x, uv.y)*up + Sv(uv.x, uv.y)*vp;
}

triple transportSegment(pair uv0, pair uv1, triple v0, pen p, int n=40, bool drawEvery=true)
{
	triple v = v0;
	real vlen = length(v0);
	real dt = 1/(real)n;

	for(int i=1; i<=n; ++i) {
		real t = (i-1)*dt;

		// RK4 for v; r(t) is known analytically from (u(t),v(t))
		pair uv_t  = uvlerp(uv0, uv1, t);
		pair uv_th = uvlerp(uv0, uv1, t + dt/2);
		pair uv_t1 = uvlerp(uv0, uv1, t + dt);

		triple r_t  = rOf(uv_t);
		triple r_th = rOf(uv_th);
		triple r_t1 = rOf(uv_t1);

		triple rd_t  = rdotOf(uv_t,  uv0, uv1);
		triple rd_th = rdotOf(uv_th, uv0, uv1);
		triple rd_t1 = rdotOf(uv_t1, uv0, uv1);

		triple k1 = vprime(r_t,  rd_t,  v);
		triple k2 = vprime(r_th, rd_th, v + (dt/2)*k1);
		triple k3 = vprime(r_th, rd_th, v + (dt/2)*k2);
		triple k4 = vprime(r_t1, rd_t1, v + dt*k3);

		v = v + (dt/6)*(k1 + 2*k2 + 2*k3 + k4);

		// Numerical cleanup: enforce tangency + preserve length
		v = v - dot(v, r_t1)*r_t1;
		if(length(v) > 1e-12) v = (vlen/length(v))*v;

		if(drawEvery) drawVector(uv_t1, v, p);
	}
	return v;
}

triple transportPath(pair[] pts, triple v0, pen p, int nPerSeg=40)
{
	triple v = v0;
	for(int i=0; i<pts.length-1; ++i)
		v = transportSegment(pts[i], pts[i+1], v, p, nPerSeg, true);
	return v;
}

// --- Scene setup (choose a patch away from the south pole) ---
real uMin = 0.15, uMax = uMin+7*0.18;
real vMin = 0.10, vMax = vMin+5*0.18;
drawGrid(uMin,uMax,vMin,vMax, 0.18, 0.18);

// Draw the sphere surface (unit sphere)
draw(unitsphere, sphpen);

pair O = (0.25, 0.2);
pair A = (1.25, 0.2);
pair B = (0.25, 0.90);
pair C = (1.25, 0.90);

pair[] path1 = {O,A,C};
pair[] path2 = {O,B,C};

// Draw the two paths along coordinate lines (curved in projection)
draw(lineV(O.y, O.x, A.x), path1pen);
draw(lineU(A.x, A.y, C.y), path1pen);

draw(lineU(O.x, O.y, B.y), path2pen);
draw(lineV(B.y, B.x, C.x), path2pen);

// Mark points
dot(rOf(O), ptpen);
dot(rOf(A), ptpen);
dot(rOf(B), ptpen);
dot(rOf(C), ptpen);

//label("$O$", rOf(O), align=SW, black);
//label("$A$", rOf(A), align=SE, black);
//label("$B$", rOf(B), align=NW, black);
//label("$C$", rOf(C), align=NE, black);

// Initial tangent vector at O in the (∂u, ∂v) directions
triple eU = Su(O.x, O.y);
triple eV = Sv(O.x, O.y);
triple v0 = unit(0.3*eU + eV);

// Draw it once at the origin in black
drawVector(O, v0, black, 0.2);

// Transport along both paths and draw vectors along the way
triple vC1 = unit(transportPath(path1, v0, vec1col, 4))*0.2;
triple vC2 = unit(transportPath(path2, v0, vec2col, 4))*0.2;
triple rC = rOf(C);
drawVector3D(rC+vC1, vC2-vC1, green, length(vC2-vC1));

// label vector v^mu at O
//label("$v^{\mu}$", rOf(O+(0.2,0.1)), align=NW, black);
// label paths dy^mu and dz^mu
//label("$dy^{\mu}$", rOf((O+A)/2 + (0.0,-0.1)), align=NW, black);
//label("$dz^{\mu}$", rOf((O+B)/2 + (0.2,0.0)), align=NW, black);

// Emphasize the two resulting vectors at C (they differ due to curvature)
//drawVector(C, vC1, vec1col+linewidth(2.2), 0.2);
//drawVector(C, vC2, vec2col+linewidth(2.2), 0.2);

