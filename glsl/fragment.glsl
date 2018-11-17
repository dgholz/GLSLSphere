uniform mat4 modelViewMatrix;
const float M_PI = 3.14159265358979323846;

vec3 mccool_rand(in float x, in float y, in float z) {
  vec4 a = vec4(pow(M_PI, 4.0), exp(4.0), pow(10.0, M_PI*0.5), sqrt(1997.0));
  vec4 result = vec4(x,y,z,1.0);
  for(int i = 0; i < 3; i++) {
    result.x = fract(dot(result, a));
    result.y = fract(dot(result, a));
    result.z = fract(dot(result, a));
    result.w = fract(dot(result, a));
  }
  return result.xyz;
}

vec3 rand(in vec3 p) {
  return mccool_rand(p.x, p.y, p.z);
}

vec3 skew(vec3 point) {
  const float F3 = 1.0/3.0;
  return point + (point.x + point.y + point.z)*F3;
}

vec3 unskew(vec3 point) {
  const float G3 = 1.0/6.0;
  return point - (point.x+point.y+point.z)*G3;
}

float fade(vec3 gradient, vec3 direction) {
  float n;
  float t = 0.65 - dot(direction,direction);
  if(t<0.0) {
    n = 0.0;
  } else {
    t *= t;
    n = t * t * dot(normalize(gradient), direction);
  }
  return n;
}

float simplex_noise(vec3 point) {
  vec3 ijk = skew(point);
  vec3 ijk0 = floor(ijk);
  vec3 D0  = fract(ijk);

  // coordinates of the second and third points of the simplex
  // the fourth point is just the origin + vec3(1.0,1.0,1.0) (in simplex lattice space)
  vec3 ijk1, ijk2, ijk3 = ijk0 + vec3(1.0,1.0,1.0);
  // there are 6 simplices in each cube, and the windings are different for each one
  // we determine which one the point is in with some coefficient comparisons
  // note: conditionals are slow as balls in GLSL so this part is slow as balls
  if (D0.x >= D0.y) {
    if(D0.y >= D0.z) {
      ijk1 = vec3(1.0,0.0,0.0);
      ijk2 = vec3(1.0,1.0,0.0);
    } else if(D0.x >= D0.z) {
      ijk1 = vec3(1.0,0.0,0.0);
      ijk2 = vec3(1.0,0.0,1.0);
    } else {
      ijk1 = vec3(0.0,0.0,1.0);
      ijk2 = vec3(1.0,0.0,1.0);
    }
  } else {
    if(D0.y < D0.z) {
      ijk1 = vec3(0.0,0.0,1.0);
      ijk2 = vec3(0.0,1.0,1.0);
    } else if(D0.x < D0.z) {
      ijk1 = vec3(0.0,1.0,0.0);
      ijk2 = vec3(0.0,1.0,1.0);
    } else {
      ijk1 = vec3(0.0,1.0,0.0);
      ijk2 = vec3(1.0,1.0,0.0);
    }
  }
  vec3 xyz0 = unskew(ijk0);
  vec3 xyz1 = unskew(ijk0+ijk1);
  vec3 xyz2 = unskew(ijk0+ijk2);
  vec3 xyz3 = unskew(ijk3);
  
  vec3 d0 = point - xyz0;
  vec3 d1 = point - xyz1;
  vec3 d2 = point - xyz2;
  vec3 d3 = point - xyz3;

  vec3 gi0 = (rand(xyz0)-0.5)*2.0;
  vec3 gi1 = (rand(xyz1)-0.5)*2.0;
  vec3 gi2 = (rand(xyz2)-0.5)*2.0;
  vec3 gi3 = (rand(xyz3)-0.5)*2.0;
  
  float n0 = fade(gi0, d0);
  float n1 = fade(gi1, d1);
  float n2 = fade(gi2, d2);
  float n3 = fade(gi3, d3);
  
  return (32.0*(n0+n1+n2+n3)+1.0)*0.5;
}

vec4 intersect_ray_with_sphere(vec4 source, vec4 direction, vec4 sphere) {
  vec4 v = source - vec4(sphere.xyz,1.0);
  vec4 d = normalize(direction);
  float B = dot(v, d);
  float C = dot(v, v) - sphere.w; // == radius
  float D = B*B - C;
  vec4 hit = vec4(0.0);
  if (D > 0.0) {
    hit = source + d*(-B - sqrt(D));
    hit.w = 1.0; // indicate sucessful instersection
  }
  return hit;
}

varying vec4 vertex; // cube vertex in model space
uniform vec3 camera_pos;
uniform float grain;
uniform float harmony;
vec4 sphere = vec4(0.0,0.0,0.0,1.0);

void main(void) {
  vec4 vs = vertex * vertex;
  if( vs.x >0.99 && vs.y >0.99 || vs.x >0.99 && vs.z >0.99 || vs.z >0.99 && vs.y >0.99 ) {
      gl_FragColor = vec4(1.0,0.0,0.0,1.0);
      return;
  }
  vec4 hit = intersect_ray_with_sphere(vertex, vertex-vec4(camera_pos.xyz,1.0), sphere);
  if (hit.w != 1.0) { discard; }

  hit *= grain;
  float simplex = 0.0;
  for (float i = 0.0; i < 16.0; i++) {
    simplex += simplex_noise(hit.xyz*pow(2.0,i))*pow(2.0,-i-1.0);
    if( i == harmony ) { break; }
  }
  gl_FragColor = vec4(simplex,simplex,simplex,1.0);
}
