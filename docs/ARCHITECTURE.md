# Arquitectura de Aula

**Aula** es una aplicación móvil Android de productividad y organización académica universitaria personal, 100% offline, gratuita y privada (cero servidores, cero telemetría).

---

## 1. Principios de Diseño y Filosofía
- **Offline-First Absoluto**: Todos los datos se almacenan en una base de datos local SQLite con soporte Write-Ahead Logging (WAL) y transacciones atómicas.
- **Física Real y Cero Fricción**:
  - Animaciones basadas en amortiguamiento crítico (`SpringSimulation` conforme a física Apple).
  - Escala interactiva instantánea (`PressableScale`) con histéresis de 10px.
  - Modales deslizables reactivos (`SpringSheet`) con desaceleración y efecto elástico (`rubberband`).
  - Haptics táctiles (`AppHaptics`) dosificados para cada interacción.
- **Superelipse Continua**: Esquinas redondeadas suaves con curvatura continua (`AppRadius.continuousShape`).
- **Seguridad y Privacidad**:
  - Bloqueo opcional por PIN (con sal criptográfica aleatoria de 16 bytes y hash SHA-256).
  - Desbloqueo biométrico nativo (huella digital o reconocimiento facial vía `local_auth`).
  - Cierre automático programable (`auto-lock`).

---

## 2. Estructura del Proyecto (Feature-First + Clean Architecture)

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp.router, MediaQuery clamp, lifecycle observer
│   ├── bootstrap.dart             # Inicialización async previa (SharedPreferences, NotificationService)
│   ├── router/
│   │   ├── app_router.dart        # GoRouter, StatefulShellRoute y redirecciones por bloqueo
│   │   ├── main_shell.dart        # Barra flotante translúcida (GlassSurface) con física de resorte
│   │   └── routes.dart            # Constantes de rutas
│   └── theme/
│       ├── app_theme.dart         # Temas Claro / Oscuro con elevación tonal
│       └── theme_provider.dart    # Estado de tema, acento dinámico y modo accesibilidad
├── core/
│   ├── database/                  # Drift ORM (SQLite en modo WAL con PRAGMA foreign_keys = ON)
│   │   ├── daos/                  # ProfileDao, SubjectsDao, ExamsDao, TopicsDao, GradesDao
│   │   ├── tables/                # Definición de tablas relacionales
│   │   └── app_database.dart      # Singleton Drift con verificación PRAGMA integrity_check
│   ├── design_system/             # Tokens y componentes reutilizables
│   │   ├── components/            # AppButton, AppCard, AppChip, AppTextField, EmptyState, SpringSheet...
│   │   └── tokens/                # AppColors, AppSpacing, AppRadius, AppMotion, AppTypography
│   ├── errors/                    # Result<T>, Success<T>, Error<T>, Failure monad
│   ├── services/                  # FileService, NotificationService, SecurityService, BackupService
│   └── utils/                     # AppHaptics, PhysicsHelpers
└── features/
    ├── onboarding/                # Flujo de bienvenida y setup inicial en 4 pasos físicos
    ├── profile/                   # Perfil estudiantil, edición de datos y avatar centrado
    ├── subjects/                  # CRUD de asignaturas, colores, iconos, estado y soft-delete
    ├── exams/                     # Evaluaciones, fechas, vinculación de recuperatorios, detección de conflictos
    ├── topics/                    # Temas con reordenamiento atómico por arrastre y progreso visual
    ├── grades/                    # Registro de calificaciones, promedios ponderados, calculadora de metas
    ├── home/                      # Resumen diario, saludo, próxima evaluación y accesos directos
    ├── calendar/                  # Calendario mensual y agenda cronológica con filtro por materia
    ├── search/                    # Búsqueda global unificada en tiempo real
    └── settings/                  # Ajustes de apariencia, seguridad, exportación/importación y zona de peligro
```

---

## 3. Sistema de Respaldos de 3 Capas
1. **Respaldos Locales Rotativos Automáticos**:
   - Cada vez que la app pasa a segundo plano, se ejecuta un respaldo silencioso en el directorio privado de la app.
   - Se conservan estrictamente las 5 copias más recientes, rotando y eliminando las anteriores.
2. **Exportación Manual Portátil (ZIP con SHA-256)**:
   - Checkpoint del WAL de SQLite (`PRAGMA wal_checkpoint(TRUNCATE);`).
   - Genera un archivo ZIP con la base de datos `aula_database.sqlite`, las fotos de perfil y un `manifest.json` con metadatos y suma de comprobación criptográfica SHA-256.
   - **Cifrado Opcional AES-GCM (256 bits)**: Si el usuario define contraseña, se cifra el contenido con AES-GCM utilizando una clave derivada con sal aleatoria.
   - Se comparte mediante la hoja nativa del sistema (`share_plus`).
3. **Importación y Verificación de Integridad**:
   - Permite seleccionar cualquier archivo de respaldo (`file_picker`).
   - Si está cifrado, solicita la contraseña para desencriptar.
   - Valida la suma SHA-256 del archivo SQLite antes de restaurar para prevenir corrupción.
