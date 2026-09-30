# BellApp

Campanas emparejadas a distancia. Toca o agita una y suenan las dos, aunque la app receptora esté cerrada (FCM de alta prioridad + servicio en primer plano).

- Android, Flutter
- Emparejado con un código de 6 dígitos
- El emisor necesita la app abierta para tocar o agitar
- El receptor puede tener la app cerrada y aun así oirá la campana

## Requisitos

- Flutter 3.47 (o el SDK del repo)
- JDK 17
- Android SDK
- Proyecto Firebase en **plan Blaze** (Cloud Functions)
- Node.js 20 para las Functions

## Conectar Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com).
2. Añade una app Android con el id `com.sara.bellapp`.
3. Descarga `google-services.json` y colócalo en `android/app/google-services.json`.
   Sin este archivo el FCM **no despierta** la app cerrada.
4. Activa Authentication (anónimo), Cloud Firestore y Cloud Messaging.
5. Pasa el proyecto a plan Blaze.
6. Rellena `lib/firebase_options.dart` (valores `YOUR_*`) o ejecuta:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=TU_PROJECT_ID --platforms=android --yes
```

7. En `.firebaserc` sustituye `YOUR_PROJECT_ID`.
8. Despliega reglas y la Function que envía el push:

```bash
cd functions
npm install
cd ..
firebase deploy --only firestore,functions
```

## Ejecutar

```bash
flutter pub get
flutter run
```

Haz la prueba en **dos móviles físicos**:

1. En A: Crear campana y anotar el código.
2. En B: Unirse con código.
3. Con B abierto: toca o agita A. Deben sonar las dos.
4. Cierra B (recientes → deslizar). Toca A. B debe sonar y mostrar la notificación.

Si un fabricante (Xiaomi, Huawei, Oppo) silencia el push, desactiva la optimización de batería para BellApp.

## Cómo llega el sonido con la app cerrada

1. El emisor escribe `rooms/{codigo}/rings/{id}` en Firestore.
2. La Cloud Function `onRingCreated` manda un mensaje FCM **solo data**, prioridad alta, al token del otro móvil.
3. `RingMessagingService` arranca `RingForegroundService` (`mediaPlayback`).
4. `MediaPlayer` reproduce `res/raw/bell.mp3` con el volumen de tono y muestra una notificación.
5. Si Android degrada la prioridad y no deja arrancar el servicio, se muestra la notificación de respaldo (también con el sonido de la campana).
