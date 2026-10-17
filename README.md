# Aula 🎓

**Aula** es una aplicación Android personal para estudiantes universitarios donde organizas tu vida académica: fechas de parciales, recuperatorios y finales, temas a estudiar, notas y promedios, todo con recordatorios locales.

- **100% Gratuita y Libre**
- **100% Offline**: Sin servidores, sin cuentas, sin rastreo de datos.
- **Física Real**: Animaciones con física de resorte Apple, esquinas en superelipse continua y haptics integrados.
- **Seguridad**: Bloqueo con PIN de 4 dígitos (con sal criptográfica y SHA-256) y autenticación biométrica (Huella / Rostro).
- **Copias de Seguridad**: Respaldos locales rotativos automáticos + exportación ZIP con verificación de integridad SHA-256 y cifrado opcional AES-GCM de 256 bits.

---

## 🚀 Características Principales

1. **Dashboard de Inicio**:
   - Saludo contextual según la hora del día.
   - Tarjeta destacada de la próxima evaluación con cuenta regresiva en vivo.
   - Acciones rápidas (nueva materia, nuevo examen, registrar nota).
   - Resumen de métricas académicas (promedio general, materias cursando).

2. **Gestión de Materias**:
   - Materias con colores y pictogramas personalizables.
   - Estados: *En curso*, *Aprobada*, *Regularizada*, *Recursar*, *Abandonada*.
   - Horarios de cursada semanales con detección automática de solapamientos.
   - Eliminación lógica (*soft delete*) con botón de "Deshacer" en SnackBar.

3. **Exámenes y Temas de Estudio**:
   - Tipos de evaluación: Parcial, Final, Recuperatorio, TP / Entrega.
   - Vinculación inteligente de recuperatorios a su examen de origen.
   - Detección proactiva de colisiones de exámenes el mismo día.
   - Lista interactiva de temas con reordenamiento físico por arrastre y barra de progreso.

4. **Calificaciones y Estadísticas**:
   - Cálculo automático de promedios simples y ponderados.
   - Calculadora "¿Cuánto necesito para aprobar / promocionar?".
   - Gráficos interactivos de evolución temporal y comparación de rendimiento por materia (`fl_chart`).

5. **Calendario y Agenda**:
   - Vista de cuadrícula mensual con indicadores visuales por materia.
   - Línea de tiempo cronológica con filtros rápidos.

6. **Búsqueda Global Unificada**:
   - Búsqueda instantánea en tiempo real a través de materias, exámenes y notas.

7. **Notificaciones Locales Confiables**:
   - Programación local con `flutter_local_notifications` y zona horaria nativa.
   - Avisos con 24h y 2h de anticipación para evaluaciones.

---

## 🛠️ Tecnologías y Arquitectura

- **Framework**: Flutter 3.35 (Dart 3.9)
- **Patrón**: Clean Architecture + Feature-First
- **Base de Datos**: SQLite nativo con Drift ORM (modo WAL, claves foráneas estrictas, transacciones atómicas).
- **Gestión de Estado**: Riverpod 2.x
- **Navegación**: GoRouter 14.x con shell flotante translúcido y protección por bloqueo reactivo.
- **Tipografía**: Fuente Inter en assets locales con tracking ajustado.
- **Seguridad**: `flutter_secure_storage` + `local_auth` + `cryptography`.

---

## 📦 Compilación y Ejecución

```bash
# Obtener dependencias
flutter pub get

# Generar código de Drift y l10n si se modifican
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# Ejecutar análisis estático (0 errores garantizados)
flutter analyze

# Ejecutar pruebas automatizadas
flutter test

# Compilar APK de Android
flutter build apk --release
```
