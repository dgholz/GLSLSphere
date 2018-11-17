var stats, scene, renderer, composer;
var camera, cameraControls;
var material;
var keyboard = new THREEx.KeyboardState();

if( !init() )    animate();

// init the scene
function init(){

    if( Detector.webgl ){
        renderer = new THREE.WebGLRenderer({
            antialias        : true,    // to get smoother output
            preserveDrawingBuffer    : true    // to allow screenshot
        });
        renderer.setClearColorHex( 0xA0FF3A, 1 );
    }else{
        Detector.addGetWebGLMessage();
        return true;
    }
    renderer.setSize( window.innerWidth, window.innerHeight );
    document.getElementById('container').appendChild(renderer.domElement);

    // add Stats.js - https://github.com/mrdoob/stats.js
    stats = new Stats();
    stats.domElement.style.position    = 'absolute';
    stats.domElement.style.bottom    = '0px';
    document.body.appendChild( stats.domElement );

    // create a scene
    scene = new THREE.Scene();

    // put a camera in the scene
    camera    = new THREE.PerspectiveCamera(35, window.innerWidth / window.innerHeight, 1, 10000 );
    camera.position.set(0, 0, 5);
    scene.add(camera);

    // create a camera contol
    cameraControls    = new THREEx.DragPanControls(camera)

    // transparently support window resize
    THREEx.WindowResize.bind(renderer, camera);
    // allow 'p' to make screenshot
    THREEx.Screenshot.bindKey(renderer);
    // allow 'f' to go fullscreen where this feature is supported
    if( THREEx.FullScreen.available() ){
        THREEx.FullScreen.bindKey();        
        document.getElementById('inlineDoc').innerHTML    += "- <i>f</i> for fullscreen";
    }

    var vertex_shader   = document.getElementById('vertex_shader').textContent;
    var fragment_shader = document.getElementById('fragment_shader').textContent;
    var uniforms = {
        camera_pos: {
            type: 'v3',
            value: new THREE.Vector3(),
        },
        grain: {
             type: 'f',
             value: 1.0,
        },
        harmonics: {
             type: 'f',
             value: 4.0,
        },
    };

    var geometry    = new THREE.CubeGeometry( 2, 2, 2 );
    material        = new THREE.ShaderMaterial({
                          ambient:        0x808080, 
                          uniforms:       uniforms,
                          vertexShader:   vertex_shader,
                          fragmentShader: fragment_shader,
                      });
    var mesh = new THREE.Mesh( geometry, material ); 
    scene.add( mesh );
}

// animation loop
function animate() {

    // loop on request animation loop
    // - it has to be at the begining of the function
    // - see details at http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
    requestAnimationFrame( animate );

    // do the render
    render();

    // update stats
    stats.update();

}

// render the scene
function render() {
    // variable which is increase by Math.PI every seconds - usefull for animation
    var PIseconds    = Date.now() * Math.PI;

    // update camera controls
    cameraControls.update();

    if ( material && camera ) {
        // https://github.com/mrdoob/three.js/issues/1188
        // var viewMatrix       = camera.matrixWorld.clone();
        // var modelMatrix      = mesh.matrixWorld.clone();
        // var modelViewMatrix  = camera.matrixWorld.clone().multiplySelf( mesh.matrixWorld );
        // material.uniforms.modelViewMatrixInverse.value.getInverse( modelViewMatrix );
        material.uniforms.camera_pos.value = camera.position;
    }
    if( keyboard.pressed("a") ) {
        material.uniforms.grain.value += 0.1;
        document.getElementById('grain').innerHTML = material.uniforms.grain.value.toFixed(1);
    }
    if( keyboard.pressed("z") && material.uniforms.grain.value > 1) {
        material.uniforms.grain.value -= 0.1;
        document.getElementById('grain').innerHTML = material.uniforms.grain.value.toFixed(1);
    }
    if( keyboard.pressed("s") && material.uniforms.harmonics.value < 8) {
        material.uniforms.harmonics.value += 1.0;
        document.getElementById('harmonics').innerHTML = material.uniforms.harmonics.value;
    }
    if( keyboard.pressed("x") && material.uniforms.harmonics.value > 1) {
        material.uniforms.harmonics.value -= 1.0;
        document.getElementById('harmonics').innerHTML = material.uniforms.harmonics.value;
    }


    // actually render the scene
    renderer.render( scene, camera );
}
