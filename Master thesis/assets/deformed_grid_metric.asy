// asy -f png -render 5 deformed_grid_metric.asy
size(12cm);
import graph;
currentlight.background = rgb(1,1,1);

pen gridpen = gray(0.6)+linewidth(1.2);
pen axespen = gray(0.3)+linewidth(1.2);
pen connpen = red+linewidth(1.5);
pen ptpen   = blue+linewidth(4);

// --- Domain in "coordinate space"
real xmin=-4, xmax=4;
real ymin=-4, ymax=4;

// --- Mapping from coordinate space (u,v) to drawing space (x,y).
pair F3(real u, real v)
{
  return (u,v);
}
pair F2(real u, real v)
{
  real a = 0.3;     // overall strength
  real k = pi/2;

  real x = u + a*sin(k*u)*cos(k*v);
  real y = v + a*cos(k*u)*sin(k*v);
  return (x,y);
}
pair F(real u, real v)
{
  real a = 0.3;      // amplitude of deformation
  real k = pi/2;     // frequency
  return (u, v + a*sin(k*u));
}

// --- Draw grid lines u=const and v=const
real step=1;
for(real u=ceil(xmin/step)*step; u<=xmax+1e-9; u += step) {
  draw( graph(new real(real t){return F(u,t).x;},
              new real(real t){return F(u,t).y;},
              ymin, ymax),
        gridpen );
}

for(real v=ceil(ymin/step)*step; v<=ymax+1e-9; v += step) {
  draw( graph(new real(real t){return F(t,v).x;},
              new real(real t){return F(t,v).y;},
              xmin, xmax),
        gridpen );
}

// --- Axes
draw(F(xmin,0)--F(xmax,0), axespen);
draw(F(0,ymin)--F(0,ymax), axespen);

// --- Two points in coordinate space
pair Auv = (-3, -1);
pair Buv = ( 3,  1);

// Mapped points
pair A = F(Auv.x, Auv.y);
pair B = F(Buv.x, Buv.y);

// Connection (straight line in coordinate space; under F it may curve)
int N=100;
path conn = A;
for(int i=1;i<=N;++i){
  real t=i/(real)N;
  real u=(1-t)*Auv.x + t*Buv.x;
  real v=(1-t)*Auv.y + t*Buv.y;
  conn = conn -- F(u,v);
}
draw(conn, connpen);

dot(A, ptpen);
dot(B, ptpen);
//label("$A$", A, SW);
//label("$B$", B, NE);
