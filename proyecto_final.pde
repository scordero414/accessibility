import websockets.*;
import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;
import guru.ttslib.*;
import java.util.Map;


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
  TXT_CONFIRMATION = "yes, boss", 
  TXT_LED_ENCENDIDO = "turn lights on", 
  TXT_LED_APAGADO = "turn lights off", 
  VACIO = "", 
  MSG_MAL_COMANDO = "unknown command", 
  TXT_MOTOR_ENCENDIDO = "turn fan on", 
  TXT_MOTOR_APAGADO = "turn fan off",
  TXT_ALARMA_ENCENDIDO = "turn on the alarm ",
  TXT_ALARMA_APAGADO = "turn off the alarm ";


void setup() {
  size(400, 400);

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
  background(0);
  txtObtenido = txtObtenido.toLowerCase().trim();
  print(txtObtenido);
  
  int opcionBot = 0;
  try {
    opcionBot = opcionesBot.get(txtObtenido);
  } catch(NullPointerException e) {
    opcionBot = -1;
  }
        
  switch(opcionBot) {
  case 0:
    println("");
    break;
  case 1: 
    arduino.digitalWrite(ledPin, Arduino.HIGH);
    tts.speak(TXT_CONFIRMATION + TXT_LED_ENCENDIDO);
    break;
  case 2: 
    arduino.digitalWrite(ledPin, Arduino.LOW);
    tts.speak(TXT_CONFIRMATION + TXT_LED_APAGADO);
    break;
  case 3:
    arduino.analogWrite(motorPin, 255);
    tts.speak(TXT_CONFIRMATION + TXT_MOTOR_ENCENDIDO); 
    break;
  case 4:
    arduino.analogWrite(motorPin, 0);
    tts.speak(TXT_CONFIRMATION + TXT_MOTOR_APAGADO);
    break;
  case 5:
    arduino.digitalWrite(alarmaPin, 1);
    tts.speak(TXT_CONFIRMATION + TXT_ALARMA_ENCENDIDO);
    break;
  case 6:
    arduino.digitalWrite(alarmaPin, 0);
    tts.speak(TXT_CONFIRMATION + TXT_ALARMA_APAGADO);
    break;
  default:
    tts.speak(MSG_MAL_COMANDO);
  }
    
  txtObtenido = VACIO;  
  delay(1000);
}


void inicializarOpcionesBot() {
  opcionesBot.put(VACIO, 0);
  opcionesBot.put(TXT_LED_ENCENDIDO, 1);
  opcionesBot.put(TXT_LED_APAGADO, 2);
  opcionesBot.put(TXT_MOTOR_ENCENDIDO, 3);
  opcionesBot.put(TXT_MOTOR_APAGADO, 4);
  opcionesBot.put(TXT_ALARMA_ENCENDIDO, 5);
  opcionesBot.put(TXT_ALARMA_APAGADO, 6);
}


void webSocketServerEvent(String msg) {  
  txtObtenido = msg;
}
