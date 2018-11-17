varying vec4 vertex;

void main() {
  //Transform vertex by modelview and projection matrices
  gl_Position = projectionMatrix *
                modelViewMatrix *
                vec4(position,1.0);
  vertex = vec4( position, 1.0 );
}
