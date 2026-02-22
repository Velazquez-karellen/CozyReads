# 📚 CozyReads — Flutter Reading Tracker

CozyReads es una aplicación multiplataforma desarrollada en **Flutter** para gestionar tu biblioteca personal, seguir tu progreso de lectura y visualizar estadísticas.  
Está diseñada con un enfoque moderno, arquitectura limpia y backend en **Supabase**.

---

## ✨ Características Principales

- 📖 Gestión de libros:
    - To Read
    - Reading
    - Read
- ➕ Añadir libros fácilmente
- 📊 Estadísticas de lectura
- 🔐 Autenticación con Supabase
- 🎨 UI basada en Material 3
- 🖥️ Soporte para Windows Desktop
- ⚡ State Management con Riverpod

---

## 🧰 Stack Tecnológico

- **Flutter**
- **Dart**
- **Riverpod**
- **Supabase (Auth + Database)**
- **Material 3**
- **CMake (Windows Desktop build)**

---

## 📦 Requisitos

- Flutter SDK instalado
- Dart (incluido en Flutter)
- Para Windows:
    - Visual Studio con *Desktop development with C++*
    - Windows 10/11 SDK

Verifica Flutter con:

```bash
flutter --version
```

---

## 🚀 Instalación

### 1️⃣ Clonar el repositorio

```bash
git clone <TU_REPO_URL>
cd CozyReads/frontend/reading_app
```

⚠️ Asegúrate de estar en la carpeta donde está el archivo `pubspec.yaml`.

---

### 2️⃣ Instalar dependencias

```bash
flutter pub get
```

---

## 🔐 Configuración de Supabase

Necesitas:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Opción A: Archivo .env (Recomendado)

Crea un archivo `.env` en la raíz de `reading_app/`:

```env
SUPABASE_URL=https://xxxxxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Asegúrate de que tu proyecto cargue correctamente las variables de entorno.

---

### Opción B: Configuración directa (solo desarrollo)

Define tus credenciales en tu archivo de configuración:

```dart
const supabaseUrl = 'https://xxxxxxxxxxxxxxxx.supabase.co';
const supabaseAnonKey = 'your-anon-key';
```

## ▶️ Ejecutar la aplicación

### Windows

```bash
flutter run -d windows
```

### Web / Mobile

```bash
flutter run
```

---

## 🏗️ Build Producción (Windows)

```bash
flutter build windows --release
```

El ejecutable se encuentra en:

```
build/windows/x64/runner/Release/
```

---

## 🧪 Ejecutar Tests

```bash
flutter test
```

---

## 🛠️ Solución de Problemas

### ❗ Error: No pubspec.yaml file found

Estás ejecutando comandos fuera de la carpeta correcta.  
Muévete a:

```bash
cd frontend/reading_app
```

---

### ❗ Error CMake (Visual Studio generator mismatch)

Si ves algo como:

```
Does not match the generator used previously: Visual Studio 17 2022
```

Ejecuta:

```powershell
flutter clean
Remove-Item -Recurse -Force .\build\windows -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .\windows\flutter\ephemeral -ErrorAction SilentlyContinue
flutter pub get
flutter run -d windows
```

---

### ❗ Supabase Paused

Si tu proyecto Supabase está en **Paused**, la app no podrá autenticar ni obtener datos.

Solución:

- Ve al Dashboard de Supabase
- Resume / Restore el proyecto
- Espera a que esté en estado Healthy

---

### ❗ Error SocketException / Failed host lookup

Indica problema de red o DNS:

- Verifica conexión a internet
- Prueba otro WiFi / hotspot
- Desactiva VPN
- Cambia DNS a 1.1.1.1 o 8.8.8.8
- Verifica que tu `SUPABASE_URL` esté correcto y tenga `https://`

---

## 🧠 Arquitectura General

- UI separada por pantallas y widgets
- Gestión de estado con Riverpod
- Servicios dedicados para Supabase
- Sistema de temas y paletas personalizadas
- Separación clara entre lógica y presentación

---

## 🗺️ Roadmap Futuro

- Offline-first support
- Metas de lectura mensuales
- Importación por ISBN
- Gamificación (streaks)
- Animaciones y mejoras UI
- Dashboard avanzado de estadísticas

---

## 🤝 Contribuir

```bash
git checkout -b feature/nueva-feature
git commit -m "Add nueva feature"
git push origin feature/nueva-feature
```

Luego crea un Pull Request.

---

## 📄 Licencia

Define aquí tu licencia MIT

---

## 📬 Contacto

- LinkedIn: https://www.linkedin.com/in/karellen-velazquez
- Instagram: karellen6
- Email: karellen.velazquez@upr.edu

---

## 🌿 CozyReads

Construyendo el hábito de lectura, una página a la vez.