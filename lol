<!--
Partes implementadas:
- Funcionalidad básica
-Funcionalidad avanzada: sonido al entrar en contacto con los bordes laterales.
-->
<!DOCTYPE html>
<html>

<head>
<title>Pong Alisson Guanga</title>

<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/103/three.min.js"></script>
<style>
   #menu{
      position: absolute;
      top: 50px;
      left: 50px;
      text-align: center;
      color:black;
      font-size:40px;
   }
</style>

<script>
   
   var ejeX = 0.15;
   var ejeY = 0.25;
   var vel=0;
   var usuario;
   var CPU;
   var puntos_usuario=0;
   var puntos_CPU=0;
   var play = false;
   const listener = new THREE.AudioListener();
   function init() {
      

      var scene = new THREE.Scene();
     // scene.background = new.THREE.Color(0x2a3b4c);
      var sceneWidth = window.innerWidth - 20;
      var sceneHeight = window.innerHeight - 20;
      

      var camera = new THREE.PerspectiveCamera(90, sceneWidth / sceneHeight, 0.01, 100);
      camera.position.set(0, -10, 15);
      camera.lookAt(scene.position);
      camera.add( listener );

      var renderer = new THREE.WebGLRenderer({
         antialias : true
      });
      renderer.shadowMap.enabled = true;
      renderer.setSize(sceneWidth, sceneHeight);
      document.body.appendChild(renderer.domElement);

      var light = getLight();
      var leftBorder = getBorder("left",1, 20, 2.5, -5, 0, 0);
      var rightBorder = getBorder("right", 1, 20, 2.5, 5, 0, 0);
      CPU = getBorder("top", 3, 1, 2, 0, 10, 0);
      usuario = getBorder("down", 4, 1, 2, 0, -9.5, 0);
      var sphere = getSphere();
      var floor = getFloor();
      /*FONDO*/
      var fondo = 'madera.jpg';
      new THREE.TextureLoader().load(fondo, function(img_madera){
         scene.background = img_madera;
      });
      
      scene.add(light);
      scene.add(leftBorder);
      scene.add(rightBorder);
      scene.add(CPU);
      scene.add(usuario);
      scene.add(sphere);
      scene.add(floor);

      var borders = [ leftBorder, rightBorder, CPU, usuario ];

      mover_teclado(scene);
      mostrar_puntos(sphere,scene)
      animate(sphere, borders, renderer, scene, camera);
      play = false;
   }

   function mover_teclado(scene){
      var x = usuario.position.x;
      var x_CPU = CPU.position.x;
      document.onkeydown = function(ev) {

        switch (ev.keyCode) {

         case 32: //tecla espacio para (re)iniciar el juego
            play = true;
             comenzar();

           break;
         case 37: // tecla para ir a la derecha
            if(usuario.position.x > -2){
              usuario.position.x -= 0.30;
            }
          break;
         case 39: //tecla para ir a la izquierda
            if(usuario.position.x < 2){
               usuario.position.x += 0.30;
            }
         }
      }  
   }
   function animate(sphere, borders, renderer, scene, camera) {
      checkCollision(sphere, borders);
      if (play == true ){
         sphere.position.x += (ejeX * vel);
         sphere.position.y += (ejeY * vel);
      }


      if (CPU.position.x < 2 || CPU.position.x > -2) {
         CPU.position.x = (0.1-(sphere.position.x/2));
         
      }
      mostrar_puntos();
      exit_ball(sphere,scene);
      mostrar_ganador();
      renderer.render(scene, camera);
      
      requestAnimationFrame(function() {
         animate(sphere, borders, renderer, scene, camera);
      });
   }
   
   function getLight() {
      var light = new THREE.DirectionalLight();
      light.position.set(4, 4, 4);
      light.castShadow = true;
      light.shadow.camera.near = 0;
      light.shadow.camera.far = 16;
      light.shadow.camera.left = -8;
      light.shadow.camera.right = 5;
      light.shadow.camera.top = 10;
      light.shadow.camera.bottom = -10;
      light.shadow.mapSize.width = 4096;
      light.shadow.mapSize.height = 4096;
      return light;
   }
   //coordenadas de inicio
   function comenzar(){
      play = true;
      var x = usuario.position.x;
      var x_CPU = CPU.position.x;
      if (play == true) {
         if ((x < 1) ||( x_CPU < 1)){
            ejeX=0.22;//
            ejeY=0.15;//
        } else if ( x > 1 || x_CPU >1) {
            ejeX=0.32;//
            ejeY=0.25;//
        }
      }
      else if (play == false){
         puntos_CPU = 0;
         puntos_usuario = 0;
         CPU.position.x = 0;
         usuario.position = 0;
      }

   }
   function getSphere() {
      var geometry = new THREE.SphereGeometry(1, 20, 20);
      var texture = new THREE.TextureLoader().load("ball.jpg");
      var material = new THREE.MeshPhongMaterial({
       map : texture
      });
      var mesh = new THREE.Mesh(geometry, material);
      mesh.position.z = 1;
      mesh.castShadow = true;
      mesh.name = "sphere";

      return mesh;
   }

   function getFloor() {
      var geometry = new THREE.PlaneGeometry(10, 20);
      var mesh = new THREE.Mesh(geometry, getWoodMaterial());
      mesh.receiveShadow = true;

      return mesh;
   }

   function getBorder(name, x, y, z, posX, posY, posZ) {
      var geometry = new THREE.BoxGeometry(x, y, z);
      var mesh = new THREE.Mesh(geometry, getWoodMaterial());
      mesh.receiveShadow = true;
      mesh.position.set(posX, posY, posZ);
      mesh.name = name;

      return mesh;
   }

   function getWoodMaterial() {
      var texture = new THREE.TextureLoader().load("fondo1.jpg");
      var material = new THREE.MeshPhysicalMaterial({
         map : texture
      });
      material.map.wrapS = material.map.wrapT = THREE.RepeatWrapping;
      material.map.repeat.set(4, 4);
      material.side = THREE.DoubleSide;
      return material;
   }
   
   function exit_ball(sphere,scene){
      if(sphere.position.y > CPU.position.y){
         //le sumo un punto  
         puntos_usuario = puntos_usuario + 1;
         
         //volvemos a la posicion inicial
         sphere.position.x = 0.0;
         sphere.position.y = 0.0;
         play = false;
         console.log(puntos_usuario);
         console.log(puntos_CPU);
         mostrar_puntos("puntos",scene);
      }

      if (sphere.position.y < usuario.position.y){
         puntos_CPU = puntos_CPU + 1;
         sphere.position.x= 0.0;
         sphere.position.y = 0.0;
         mostrar_puntos("puntos",scene);
         play = false;
         console.log(puntos_usuario);
         console.log(puntos_CPU);
      }

   }
  
   function mostrar_puntos(){
      document.getElementById('puntos').innerHTML = "Jugador:  " + puntos_usuario + " CPU: " + puntos_CPU;
   }

   function mostrar_ganador(){
      if (puntos_usuario == 5 & puntos_CPU < 5){
         jugador_ganador = "Jugador";
         document.getElementById('ganador').innerHTML = jugador_ganador;
         puntos_CPU=0;
         puntos_usuario=0;

      }else if (puntos_CPU == 5 & puntos_usuario ==5){
         jugador_ganador = "EMPATE";
         document.getElementById('ganador').innerHTML = jugador_ganador;
         puntos_CPU=0;
         puntos_usuario=0;
      }
      //En el caso de que la CPU gane
      if (puntos_usuario < 5 & puntos_CPU == 5){
         jugador_ganador = "CPU";
         document.getElementById('ganador').innerHTML = jugador_ganador;
         puntos_CPU=0;
         puntos_usuario=0;
      }else if (puntos_CPU == 5 & puntos_usuario ==5){
         jugador_ganador = "EMPATE";
         document.getElementById('ganador').innerHTML = jugador_ganador;
         puntos_CPU=0;
         puntos_usuario=0;
      }
   }

   


   // create a global audio source
   const sound = new THREE.Audio( listener );

   function sonido_collision(){
         // load a sound and set it as the Audio object's buffer
      console.log("musica")
      const audioLoader = new THREE.AudioLoader();
      audioLoader.load( 'ping.mp3', function( buffer ) {
	   sound.setBuffer( buffer );
	   sound.setLoop( false );
	   sound.setVolume( 0.5);
	   sound.play();
  
   });
   }
   
   //detección de colisiones
   function checkCollision(sphere, borders) {
      var originPosition = sphere.position.clone();
      var x = usuario.position.x;
      var x_CPU = CPU.position.x;

      for (var i = 0; i < sphere.geometry.vertices.length; i++) {
         var localVertex = sphere.geometry.vertices[i].clone();
         var globalVertex = localVertex.applyMatrix4(sphere.matrix);
         var directionVector = globalVertex.sub(sphere.position);
         var ray = new THREE.Raycaster(originPosition, directionVector.clone().normalize());
         var collisionResults = ray.intersectObjects(borders);
         if (collisionResults.length > 0 && collisionResults[0].distance < directionVector.length()) {
            // Colision en el lateral
            if (collisionResults[0].object.name == "left" || collisionResults[0].object.name == "right") {
               ejeX *= -1;
               sonido_collision();
            }
            //collision detected in USER
            if (collisionResults[0].object.name == "down") {
               ejeY *=-1;
               if (x < 0.85){
                  vel = 0.85;
               }else if( x>0.85){
                  vel=1.05;
               }
            }
            //collision detected in CPU
            if (collisionResults[0].object.name == "top") {
               ejeY *= -1;
               if (x_CPU > 0.85){
                  vel = 1.05;
               } else if(x_CPU < 0.85){
                  vel=0.85;
               }
            }   
         }
      }
   }

      
  
</script>

</head>

<body onload="init()">
   <div id="puntos"></div>
   <span style="color: blueviolet;">JUGADOR GANADOR ES:</span>
   <div id="ganador"></div>
</body>

</html>

