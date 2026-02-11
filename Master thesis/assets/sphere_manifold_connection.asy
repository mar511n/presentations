// asy -f png -render 5 sphere_manifold_connection.asy
import three;
size(12cm);
currentprojection=perspective(5,3,2);
currentlight.background = rgb(1,1,1);

real R=1;
triple O=(0,0,0);

pen sphpen  = gray(0.85) + opacity(0.6);
pen edgepen = black + linewidth(1.2);
pen planepen= rgb(0.7,0.85,1.0) + opacity(0.45);
pen curvepen= red + linewidth(1.5);

// Sphere (built-in mesh) scaled to radius R and shifted to center O
draw(shift(O)*scale3(R)*unitsphere, sphpen);

// Tangency points
triple P1 = O + R*(1,1,1.5)/sqrt(17/4);
triple P2 = O + R*(1,0,0);

// Tangent plane patch (parallelogram) at point P on the sphere
void tangentPlanePatch(triple P, real s)
{
  triple n = unit(P-O);          // sphere normal at P

  triple a=(0,0,1);
  if(abs(dot(a,n)) > 0.9) a=(0,1,0);
  triple u = unit(cross(n,a));
  triple v = cross(n,u);

  triple A=P + s*( u + v);
  triple B=P + s*(-u + v);
  triple C=P + s*(-u - v);
  triple D=P + s*( u - v);

  draw(surface(A--B--C--D--cycle), planepen);
  draw(A--B--C--D--cycle, edgepen);
}

// Draw tangent basis vectors (u,v) at point P on the sphere
void tangentBasis(triple P, real x1, real x2, real y1, real y2, real L=0.35)
{
  triple n = unit(P-O);

  triple a=(0,0,1);
  if(abs(dot(a,n)) > 0.9) a=(0,1,0);
  triple u = unit(cross(a,n));
  triple v = cross(n,u); // already unit if n,u are unit and orthogonal
  triple x = u*x1 + v*x2;
  triple y = u*y1 + v*y2;

  draw(P--(P+0.8*L*x), orange+linewidth(1.8));
  draw(P--(P+0.8*L*y), purple+linewidth(1.8));

  draw(P--(P+L*x), orange, Arrow3);
  draw(P--(P+L*y), purple, Arrow3);
}

tangentPlanePatch(P1,0.5);
tangentPlanePatch(P2,0.5);

dot(P1); dot(P2);

tangentBasis(P1, 0, 1, -1, 0, 0.25);
tangentBasis(P2, 1, 0, 0, 1, 0.25);

// Curve connecting the two tangency points (great-circle arc), drawn as segments
int N=80;
triple Qprev = P1;
for(int i=1; i<=N; ++i){
  real t = i/N;
  triple Q = P1*(1-t) + P2*t + (0.4,0.5,0)*(1-(2*t-1)**2) - O;
  Q = Q/abs(Q);
  Q = Q + O;
  draw(Qprev--Q, curvepen);
  Qprev = Q;
}
