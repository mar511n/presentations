// asy -f png -render 5 graphene_5_7_defect_positions.asy

import three;

size(12cm);
currentlight.background = rgb(1,1,1);
// A mostly top-down view so the spheres read as 2D markers.
currentprojection=perspective(0,4,3);

pen spherepen = rgb(0.10,0.10,0.10) + opacity(1.0);

// --- Parsing helpers ---
bool isNumChar(string ch)
{
	// digits, sign, decimal point, exponent markers
	return (ch >= "0" && ch <= "9") || ch == "+" || ch == "-" || ch == "." || ch == "e" || ch == "E";
}

real[] parseReals(string s)
{
	real[] out;
	string tok = "";

	for(int i=0; i < length(s); ++i) {
		string ch = substr(s,i,1);
		if(isNumChar(ch)) {
			tok += ch;
		} else {
			if(length(tok) > 0) {
				out.push((real) tok);
				tok = "";
			}
		}
	}
	if(length(tok) > 0) out.push((real) tok);
	return out;
}

pair[] parsePairs(string s)
{
	real[] xs = parseReals(s);
	pair[] pts;

	int n = (int) floor(xs.length/2);
	for(int i=0; i < n; ++i) {
		pts.push( (xs[2*i], xs[2*i+1]) );
	}
	if(xs.length % 2 == 1) {
		write("Warning: odd count of numbers in positions string; last number ignored.");
	}
	return pts;
}

// --- User input ---
// Paste your positions string here.
string positionsStr = "0.9913396167 -0.5549326773
0.8716330787 -0.6370449349
0.7422973053 -0.5745218004
0.6216368938 -0.6554781750
0.4963741374 -0.5926438962
0.3763641173 -0.6709879359
0.2513496598 -0.6067401852
0.1294523175 -0.6835429489
0.0035245297 -0.6133723930
-0.1215888743 -0.6848289144
-0.2446974055 -0.6091344328
-0.3693203756 -0.6749786487
-0.4907049065 -0.5977209134
-0.6152434722 -0.6618677648
-0.7370225546 -0.5818255151
-0.8652238902 -0.6451820429
-0.9857312363 -0.5640309497
-0.9756637558 -0.4212610079
-0.8493466564 -0.3599736863
-0.7282489709 -0.4414148869
-0.6039418665 -0.3797490694
-0.4842668174 -0.4579974405
-0.3605876991 -0.3943014158
-0.2400270187 -0.4704601016
-0.1178552384 -0.4043130663
0.0028622069 -0.4750571281
0.1229098621 -0.4030730191
0.2451959804 -0.4677234532
0.3648901896 -0.3905278918
0.4884341838 -0.4527533362
0.6070627731 -0.3735487419
0.7321858496 -0.4341733934
0.8524714178 -0.3515462151
0.9798866228 -0.4118203701
1.0978515099 -0.3300337808
1.0854210963 -0.1877491651
0.9577638920 -0.1290812511
0.8405842311 -0.2118970020
0.7127338320 -0.1525976327
0.5965793999 -0.2335171255
0.4703099128 -0.1738038077
0.3562082419 -0.2520664184
0.2354521928 -0.1931947156
0.1187843759 -0.2695361029
0.0015558364 -0.2051592235
-0.1149263416 -0.2705949843
-0.2324888319 -0.1954424056
-0.3533087657 -0.2557147479
-0.4681289409 -0.1785578349
-0.5946339032 -0.2397403851
-0.7115556574 -0.1597594512
-0.8387964855 -0.2201274764
-0.9565278331 -0.1385505265
-1.0831919381 -0.1981840535
-1.0943861636 -0.3405745353
-1.0613859171 0.0831628679
-0.9445493838 0.0009807900
-0.8154389185 0.0608107351
-0.6996890373 -0.0206918659
-0.5687217229 0.0395987145
-0.4564478185 -0.0402473908
-0.3273917018 0.0176942198
-0.2211685221 -0.0603494149
-0.1017463249 -0.0102995005
0.0008453286 -0.0799809682
0.1025182347 -0.0094586593
0.2226974650 -0.0582949074
0.3279509267 0.0207311143
0.4572402702 -0.0356075778
0.5682447013 0.0451611648
0.6995976367 -0.0136366619
0.8143051297 0.0688274296
0.9444134321 0.0101511113
1.0605302705 0.0937148016
1.0449808252 0.2371818493
0.9144134508 0.2937701167
0.7994828259 0.2088175885
0.6652084999 0.2676198072
0.5526287751 0.1845377276
0.4157600371 0.2430896454
0.3085197873 0.1599285467
0.1623898057 0.2127002143
0.0692337954 0.1163219297
-0.0697535759 0.1156244605
-0.1639575843 0.2113806167
-0.3095986436 0.1569488455
-0.4179018425 0.2391561824
-0.5545811363 0.1789680577
-0.6681674416 0.2610942537
-0.8019429067 0.2010265523
-0.9174554165 0.2845253271
-1.0474984744 0.2263740853
-1.0216572021 0.5168363347
-0.9020121796 0.4288892218
-0.7707590187 0.4865586300
-0.6534710168 0.4007634843
-0.5199445260 0.4598425910
-0.4028454452 0.3748898516
-0.2669458145 0.4363633336
-0.1434297343 0.3492307369
-0.0021756963 0.4220502927
0.1402379278 0.3505769639
0.2624692296 0.4389553971
0.3990479967 0.3790803165
0.5147800752 0.4651146519
0.6490039037 0.4075908167
0.7650638243 0.4946037432
0.8971009619 0.4385985426
1.0161206831 0.5285648169
0.9980949687 0.6702479141
0.8655962618 0.7252383706
0.7478423749 0.6359473816
0.6165141685 0.6919824893
0.4987469490 0.6049175367
0.3673322111 0.6629754442
0.2493039978 0.5796451969
0.1206870213 0.6422623849
-0.0029285530 0.5672181109
-0.1275784756 0.6411685237
-0.2555576865 0.5769828881
-0.3748513257 0.6589740056
-0.5056162152 0.5993555423
-0.6241318608 0.6850196945
-0.7551368584 0.6275996748
-0.8733855065 0.7154230057
-1.0053165879 0.6589958861
";

bool usePointsFile = false;
string pointsFile = "graphene_5_7_defect_positions_points.dat";

// Optional: scale coordinates (e.g., if your positions are in lattice units).
real xyScale = 1;

// Subtract the mean position from all points (centers point cloud at the origin).
bool subtractMean = true;

// Rescale so the maximum pairwise distance becomes ~2 (i.e. points lie roughly in [-1,1]).
// This uses the *maximum distance between points* as requested.
bool rescaleByMaxPairwiseDistance = true;

// Also subtract the mean of the computed z-values (centers in z).
bool subtractMeanZ = true;

// Base sphere radius (before any rescaling). It will be scaled by the same factor as the points.
real r0 = 0.02;

// Draw connection lines between points closer than this threshold.
// Distance is computed in the (x,y) plane AFTER shift+scaling.
real connectionThreshold = 0.17;
pen connectionPen = gray(0.15) + linewidth(4.0);

pair[] positions;
if(usePointsFile) {
	file f = input(pointsFile);
	while(true) {
		if(eof(f)) break;
		real x = f;
		if(eof(f)) break;
		real y = f;
		positions.push((x,y));
	}
} else {
	positions = parsePairs(positionsStr);
}

pair meanPos = (0,0);
if(positions.length > 0) {
	for(int i=0; i < positions.length; ++i) meanPos += positions[i];
	meanPos *= 1/positions.length;
}

real dist(pair a, pair b)
{
	real dx = a.x - b.x;
	real dy = a.y - b.y;
	return sqrt(dx*dx + dy*dy);
}

real pointScale = 1;

// --- Apply shifting/scaling before drawing ---
pair[] pts2;
for(int i=0; i < positions.length; ++i) {
	pair p = positions[i];
	if(subtractMean) p -= meanPos;
	p *= xyScale;
	pts2.push(p);
}

if(rescaleByMaxPairwiseDistance && pts2.length > 1) {
	real maxD = 0;
	for(int i=0; i < pts2.length; ++i) {
		for(int j=i+1; j < pts2.length; ++j) {
			real d = dist(pts2[i], pts2[j]);
			if(d > maxD) maxD = d;
		}
	}
	if(maxD > 0) pointScale = 2/maxD;
}

for(int i=0; i < pts2.length; ++i) pts2[i] *= pointScale;

real r = r0 * pointScale;

triple[] pts3;
real meanZ = 0;
for(int i=0; i < pts2.length; ++i) {
	pair p = pts2[i];
	real z = 0.0;//exp(-0.5*(p.x/0.2)**2)*0.1 * (tanh(3*p.y)+1.0);
	meanZ += z;
	pts3.push((p.x, p.y, z));
}
if(subtractMeanZ && pts3.length > 0) {
	meanZ *= 1/pts3.length;
	for(int i=0; i < pts3.length; ++i) pts3[i] -= (0,0,meanZ);
}

// --- Connection lines ---
if(connectionThreshold > 0 && pts3.length > 1) {
	for(int i=0; i < pts3.length; ++i) {
		for(int j=i+1; j < pts3.length; ++j) {
			if(dist(pts2[i], pts2[j]) < connectionThreshold) {
				draw(pts3[i]--pts3[j], connectionPen);
			}
		}
	}
}

// --- Draw spheres ---
for(int i=0; i < pts3.length; ++i) {
	draw(shift(pts3[i])*scale3(r)*unitsphere, spherepen);
}

