// asy -f png -render 5 torsion.asy
size(10cm);
import graph3;
import solids;

currentprojection=orthographic(0.5,-5,8);
currentlight=light(white, (5,-5,10), specularfactor=3);

pen manifoldpen = gray(0.85)+opacity(0.3);
pen tangentspacepen = rgb(0.7,0.85,1.0) + opacity(0.7);
pen edgepen = gray(0.2) + linewidth(1.5);
pen vectorpen = linewidth(2.0);
pen ucol = red;
pen vcol = blue;

void drawVector3D(triple r, triple v, pen col, real L=0.2, real arrowhead_size=0.07)
{
  triple w = v;
  if(length(w) < 1e-12) return;
  w = (L/length(w))*w;

  draw(r -- (r + (1-arrowhead_size)*w), col+vectorpen);
  draw(r -- (r + w), col+linewidth(1.0), Arrow3);
}

// 1. Define the vectors and origin
triple O = (0,0,0);
triple u = (3.5, 0, 0); // u vector
triple v = (1.5, 4.0, 0); // v vector

// 2. Draw the flat plane (Infinitesimal manifold patch / tangent space at O)
// We draw a parallelogram defined by u and v
path3 p_flat = O-(u+v)/4 -- u+(u-v)/4 -- (u+v)+(u+v)/4 -- v+(-u+v)/4 -- cycle;
draw(surface(p_flat), manifoldpen);
draw(p_flat, edgepen + linetype(new real[] {4,4})); // Dashed border for reference

drawVector3D(O, u, ucol, length(u));
drawVector3D(u, v, vcol, length(v));
drawVector3D(v+u, -u, ucol, length(u));
drawVector3D(v, -v, vcol, length(v));

// 3. Draw the "Curved Tangent Space" rolled along v
real tangentspace_curvature = 0.2;
real tangentspace_height = 0.7;

triple rolled_surface(pair p) {
    real s = p.x; // Coeff for u
    real t = p.y; // Coeff for v
    
	triple posoff = u + v/3;
	triple pos = s*u + t*v;
    triple displacement = (0, 0, 1-exp(-0.5*(t/tangentspace_curvature)^2));
    
    return posoff + pos + tangentspace_height*displacement;
}

// Draw the rolled surface over the same domain [-1,1] x [-1,1]
surface s_rolled = surface(rolled_surface, (-0.5,-0.5), (0.5,0.5), 1, 100);
draw(s_rolled, tangentspacepen);

// Draw edges of rolled surface to make it distinct
path3 edge_bottom = rolled_surface((-0.5,-0.5)) -- rolled_surface((0.5,-0.5));
path3 edge_top = rolled_surface((0.5,0.5)) -- rolled_surface((-0.5,0.5));

// Construct curved edges by sampling
path3 edge_right = graph(new triple(real t) {
    return rolled_surface((0.5, t));
}, -0.5, 0.5, operator ..);

path3 edge_left = graph(new triple(real t) {
    return rolled_surface((-0.5, t));
}, 0.5, -0.5, operator ..);

draw(edge_bottom -- edge_right -- edge_top -- edge_left -- cycle, edgepen);

// 4. Draw path on the rolled surface
// Segment 1: (s,t) = (-0.5, -1/3) -> (0, -1/3). Movement along u direction (s changes).
// Color: ucol. 6 vectors.
int n1 = 6;
pair start1 = (-0.5, -1.0/3.0);
pair end1 = (0.0, -1.0/3.0);
for(int i=0; i<n1; ++i) {
    real t1 = i/n1;
    real t2 = (i+1)/n1;
    pair p1 = start1 + t1*(end1-start1);
    pair p2 = start1 + t2*(end1-start1);
    
    triple r1 = rolled_surface(p1);
    triple r2 = rolled_surface(p2);
    drawVector3D(r1, r2-r1, ucol, length(r2-r1), 0.5); 
}

// Segment 2: (s,t) = (0, -1/3) -> (0, 0). Movement along v direction (t changes).
// Color: vcol. 4 vectors.
int n2 = 4;
pair start2 = (0.0, -1.0/3.0);
pair end2 = (0.0, 0.0);
for(int i=0; i<n2; ++i) {
    real t1 = i/n2;
    real t2 = (i+1)/n2;
    pair p1 = start2 + t1*(end2-start2);
    pair p2 = start2 + t2*(end2-start2);
    
    triple r1 = rolled_surface(p1);
    triple r2 = rolled_surface(p2);
    drawVector3D(r1, r2-r1, vcol, length(r2-r1), 0.6);
}

dot(rolled_surface(end2), black+linewidth(4));