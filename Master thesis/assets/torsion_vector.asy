// asy -f png -render 5 torsion_vector.asy
size(6cm);
import graph3;
import solids;

currentprojection=orthographic(0,-0.1,8);
currentlight=light(white, (5,-5,10), specularfactor=3);

pen manifoldpen = gray(0.85)+opacity(0.3);
pen tangentspacepen = rgb(0.7,0.85,1.0) + opacity(0.9);
pen edgepen = gray(0.2) + linewidth(1.5);
pen vectorpen = linewidth(2.0);
pen ucol = red;
pen vcol = blue;

triple u = (4.0, 0, 0); // u vector
triple v = (0, 5.0, 0); // v vector


void drawVector3D(triple r, triple v, pen col, real L=0.2, real arrowhead_size=0.07)
{
  triple w = v;
  if(length(w) < 1e-12) return;
  w = (L/length(w))*w;

  draw(r -- (r + (1-arrowhead_size)*w), col+vectorpen);
  draw(r -- (r + w), col+linewidth(1.0), Arrow3);
}

// 3. Draw the "Curved Tangent Space" rolled along v
real tangentspace_curvature = 0.2;
real tangentspace_height = 0.0;

triple rolled_surface(pair p) {
    real s = p.x-0.5; // Coeff for u
    real t = p.y-0.5; // Coeff for v
    
	triple posoff = (0,0,0); //u + v/3;
	triple pos = s*u + t*v;
    triple displacement = (0, 0, 1-exp(-0.5*(t/tangentspace_curvature)^2));
    
    return posoff + pos + tangentspace_height*displacement;
}

// Draw the rolled surface over the same domain [-1,1] x [-1,1]
surface s_rolled = surface(rolled_surface, (0.1,0.1), (0.9,0.9), 1, 100);
draw(s_rolled, tangentspacepen);

// Draw edges of rolled surface to make it distinct
path3 edge_bottom = rolled_surface((0.1,0.1)) -- rolled_surface((0.9,0.1));
path3 edge_top = rolled_surface((0.9,0.9)) -- rolled_surface((0.1,0.9));

// Construct curved edges by sampling
path3 edge_right = rolled_surface((0.9,0.1)) -- rolled_surface((0.9,0.9));
path3 edge_left = rolled_surface((0.1,0.9)) -- rolled_surface((0.1,0.1));

draw(edge_bottom -- edge_right -- edge_top -- edge_left, edgepen);

// 4. Draw path on the rolled surface
// Segment 1: (s,t) = (-0.5, -1/3) -> (0, -1/3). Movement along u direction (s changes).
// Color: ucol. 6 vectors.
int n1 = 6;
pair start1 = (0.4, 0.2);
pair end1 = (0.8, 0.2);
for(int i=0; i<n1; ++i) {
    real t1 = i/n1;
    real t2 = (i+1)/n1;
    pair p1 = start1 + t1*(end1-start1);
    pair p2 = start1 + t2*(end1-start1);
    
    triple r1 = rolled_surface(p1);
    triple r2 = rolled_surface(p2);
    drawVector3D(r1, r2-r1, ucol, length(r2-r1), 0.5); 
}

dot(rolled_surface(start1), black+linewidth(4));


// Segment 2: (s,t) = (0, -1/3) -> (0, 0). Movement along v direction (t changes).
// Color: vcol. 4 vectors.
int n2 = 6;
pair start2 = (0.8, 0.2);
pair end2 = (0.8, 0.8);
for(int i=0; i<n2; ++i) {
    real t1 = i/n2;
    real t2 = (i+1)/n2;
    pair p1 = start2 + t1*(end2-start2);
    pair p2 = start2 + t2*(end2-start2);
    
    triple r1 = rolled_surface(p1);
    triple r2 = rolled_surface(p2);
    drawVector3D(r1, r2-r1, vcol, length(r2-r1), 0.4);
}

int n1 = 6;
pair start1 = (0.8, 0.8);
pair end1 = (0.2, 0.8);
for(int i=0; i<n1; ++i) {
    real t1 = i/n1;
    real t2 = (i+1)/n1;
    pair p1 = start1 + t1*(end1-start1);
    pair p2 = start1 + t2*(end1-start1);
    
    triple r1 = rolled_surface(p1);
    triple r2 = rolled_surface(p2);
    drawVector3D(r1, r2-r1, ucol, length(r2-r1), 0.4); 
}

int n2 = 6;
pair start2 = (0.2, 0.8);
pair end2 = (0.2, 0.2);
for(int i=0; i<n2; ++i) {
    real t1 = i/n2;
    real t2 = (i+1)/n2;
    pair p1 = start2 + t1*(end2-start2);
    pair p2 = start2 + t2*(end2-start2);
    
    triple r1 = rolled_surface(p1);
    triple r2 = rolled_surface(p2);
    drawVector3D(r1, r2-r1, vcol, length(r2-r1), 0.4);
}

int n1 = 1;
pair start1 = (0.4, 0.2);
pair end1 = (0.2, 0.2);
for(int i=0; i<n1; ++i) {
    real t1 = i/n1;
    real t2 = (i+1)/n1;
    pair p1 = start1 + t1*(end1-start1);
    pair p2 = start1 + t2*(end1-start1);
    
    triple r1 = rolled_surface(p1);
    triple r2 = rolled_surface(p2);
    drawVector3D(r1, r2-r1, black, length(r2-r1), 0.2); 
}