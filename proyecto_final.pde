import websockets.*;
import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;
import guru.ttslib.*;
import java.util.Map;

PImage reconocimiento_encender;
PImage reconocimiento_apagar;
PImage fondo;
PImage bombillo_activo;
PImage bombillo_inactivo;
PImage mic_activo;
PImage mic_inactivo;
PImage sonido_activo;
PImage sonido_inactivo;
PImage ventilador_activo;
PImage ventilador_inactivo;

//MANEJAR ESTADOS QUE CONTROLEN SI LAS COSAS ESTÁN ACTIVAS O INACTIVAS.
boolean estadoBombillo, estadoVentilador, estadoAlarma;
boolean estado_reconocimiento;


HashMap<String, Integer> opcionesBot = new HashMap<String, Integer>();

TTS tts;
// Comunicación con el navegador.
WebsocketServer socket;

// Manipular funciones de arduino.
Arduino arduino;
String txtObtenido;
final int ledPin = 2, motorPin = 3, alarmaPin = 4;


final int PUERTO_COM = 0;

final String MSG_BIENVENIDA = "hello, I am milo, I am at your feet, boss", 
  TXT_CONFIRMATION = "yes, boss ", 
  TXT_LED_ENCENDIDO = "turn lights on", 
  TXT_LED_APAGADO = "turn lights off", 
  VACIO = "", 
  MSG_MAL_COMANDO = "unknown command", 
  TXT_MOTOR_ENCENDIDO = "turn on the air", 
  TXT_MOTOR_APAGADO = "turn off the air", 
  TXT_ALARMA_ENCENDIDO = "turn on the alarm", 
  TXT_ALARMA_APAGADO = "turn off the alarm", 
  TXT_COMMAND_USED = "command already running", 
  TXT_CERRAR_APP = "close app";


void setup() {
  size(800, 800);

  fondo = loadImage("imágenes/fondo.png");

  reconocimiento_encender = loadImage("imágenes/reconocimiento_encender.png");
  reconocimiento_apagar = loadImage("imágenes/reconocimiento_apagar.png");

  bombillo_activo = loadImage("imágenes/bombillo_encendido.png");
  bombillo_inactivo = loadImage("imágenes/bombillo_apagado.png");

  mic_activo = loadImage("imágenes/mic_activo.png");
  mic_inactivo = loadImage("imágenes/mic_inactivo.png");

  sonido_activo = loadImage("imágenes/sonido_activo.png");
  sonido_inactivo = loadImage("imágenes/sonido_inactivo.png");

  ventilador_activo = loadImage("imágenes/ventilador_activo.png");
  ventilador_inactivo = loadImage("imágenes/ventilador_inactivo.png");

  //Inicien todos los estados en false por si acaso 
  estadoBombillo = false;
  estadoVentilador = false;
  estadoAlarma = false;
  estado_reconocimiento = false;

  // objeto para conversión de texto a voz
  tts = new TTS();  

  inicializarOpcionesBot();

  txtObtenido = "";

  //Establece la conexión, por medio de una id y puerto especificado.
  socket = new WebsocketServer(this, 1337, "/p5websocket");

  println(Arduino.list());
  //indica en que puerto queda conectado el arduino
  arduino=new Arduino(this, Arduino.list()[PUERTO_COM], 9600); 

  arduino.pinMode(ledPin, Arduino.OUTPUT);
  arduino.pinMode(motorPin, Arduino.OUTPUT);

  tts.speak(MSG_BIENVENIDA);
}

void draw() {
  image(fondo, 0, 0);


  if (estado_reconocimiento) {
    image(reconocimiento_apagar, 239, 50);
    image(mic_activo, 580, 45);

    txtObtenido = txtObtenido.toLowerCase().trim();
    //String str;
    //if(!txtObtenido.equals(""))
    //   str = txtObtenido;
    fill(0, 102, 153);
    textSize(32);
    text("Comando: ", 250, 350);
    int opcionBot = 0;
    try {
      opcionBot = opcionesBot.get(txtObtenido);
    } 
    catch(NullPointerException e) {
      opcionBot = -1;
    }

    switch(opcionBot) {
    case 0:
      println("");
      break;
    case 1: 

      if (!estadoBombillo) {
        estadoBombillo = !estadoBombillo;
        arduino.digitalWrite(ledPin, Arduino.HIGH);
        tts.speak(TXT_CONFIRMATION + TXT_LED_ENCENDIDO);
      } else {
        tts.speak(TXT_COMMAND_USED);
      }
      break;
    case 2: 
      if (estadoBombillo) {
        estadoBombillo = !estadoBombillo;
        arduino.digitalWrite(ledPin, Arduino.LOW);
        tts.speak(TXT_CONFIRMATION + TXT_LED_APAGADO);
      } else {
        tts.speak(TXT_COMMAND_USED);
      }
      break;
    case 3:
      if (!estadoVentilador) {
        estadoVentilador = !estadoVentilador; 
        arduino.analogWrite(motorPin, 255);
        tts.speak(TXT_CONFIRMATION + TXT_MOTOR_ENCENDIDO);
      } else {
        tts.speak(TXT_COMMAND_USED);
      }
      break;
    case 4:
      if (estadoVentilador) {
        estadoVentilador = !estadoVentilador; 
        arduino.analogWrite(motorPin, 0);
        tts.speak(TXT_CONFIRMATION + TXT_MOTOR_APAGADO);
      } else {
        tts.speak(TXT_COMMAND_USED);
      }
      break;
    case 5:
      if (!estadoAlarma) {
        estadoAlarma = !estadoAlarma;
        arduino.digitalWrite(alarmaPin, 1);
        tts.speak(TXT_CONFIRMATION + TXT_ALARMA_ENCENDIDO);
      } else {
        tts.speak(TXT_COMMAND_USED);
      }
      break;
    case 6:
      if (estadoAlarma) {
        estadoAlarma = !estadoAlarma;
        arduino.digitalWrite(alarmaPin, 0);
        tts.speak(TXT_CONFIRMATION + TXT_ALARMA_APAGADO);
      } else {
        tts.speak(TXT_COMMAND_USED);
      }
      break;
    case 7:
      tts.speak(TXT_CONFIRMATION + TXT_CERRAR_APP);
      exit();
      break;
    default:
      println("Unknow command");
      tts.speak(MSG_MAL_COMANDO);
    }
  } else {
    image(reconocimiento_encender, 239, 50);
    image(mic_inactivo, 580, 45);
  }

  if (estadoBombillo)
    image(bombillo_activo, 150, 450);
  else
    image(bombillo_inactivo, 150, 450);

  if (estadoVentilador)
    image(ventilador_activo, 550, 450);
  else
    image(ventilador_inactivo, 550, 450);

  if (estadoAlarma)
    image(sonido_activo, 350, 450);
  else
    image(sonido_inactivo, 350, 450);

  txtObtenido = "";
}

void mouseClicked() {
  if (mouseX > 239 && mouseX < (239 + 322) && mouseY > 50 && mouseY < (50 + 91)) {
    estado_reconocimiento = !estado_reconocimiento;
  }
}


int convertNumberWordToInt(String str) {
  String [] cifras = str.split(" ");
  String concat = "";
  for (String i : cifras) {
    concat += i;
  }
  return int(concat);
}

void inicializarOpcionesBot() {
  opcionesBot.put(VACIO, 0);
  opcionesBot.put(TXT_LED_ENCENDIDO, 1);
  opcionesBot.put(TXT_LED_APAGADO, 2);
  opcionesBot.put(TXT_MOTOR_ENCENDIDO, 3);
  opcionesBot.put(TXT_MOTOR_APAGADO, 4);
  opcionesBot.put(TXT_ALARMA_ENCENDIDO, 5);
  opcionesBot.put(TXT_ALARMA_APAGADO, 6);
  opcionesBot.put(TXT_CERRAR_APP, 7);
}


void webSocketServerEvent(String msg) {  
  if (estado_reconocimiento)
    txtObtenido = msg;
}
