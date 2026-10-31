// Importar los scripts de Firebase para el Service Worker (versión compat)
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

// Inicializar Firebase con los datos de tu proyecto
firebase.initializeApp({
  apiKey: "AIzaSyBabxDi243MydFnguqmjLoxj4FiPDvsAwE",
  authDomain: "eduquest-alerta-temprana.firebaseapp.com",
  projectId: "eduquest-alerta-temprana",
  storageBucket: "eduquest-alerta-temprana.firebasestorage.app",
  messagingSenderId: "168638303360",
  appId: "1:168638303360:web:35f939c417e597e3f2ea65"
});

// Instanciar el servicio de mensajería en segundo plano
const messaging = firebase.messaging();