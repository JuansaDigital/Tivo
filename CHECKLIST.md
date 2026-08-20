# 📋 Tivo — Checklist de Estado y Hoja de Ruta (Roadmap)

> **Última actualización:** 20 de Agosto de 2026  
> **Estado general del proyecto:** ✅ **95% Funcionalidades Core Completadas** | 🧪 **100% Tests Pasados (11/11)**

---

## 📑 Resumen Ejecutivo de Módulos

| Módulo / Feature | Estado | Descripción |
| :--- | :---: | :--- |
| **1. Sistema de Diseño & Branding** | ✅ Completado | Glassmorphism Deep Navy, Logo 3D sin artefactos, Paleta HSL dinámica. |
| **2. Autenticación & Seguridad** | ✅ Completado | Firebase Auth, Google Sign-In, Invitado, PIN dinámico, Biometría y Auto-Lock. |
| **3. Onboarding Financiero** | ✅ Completado | Flujo de bienvenida, configuración de salario, frecuencia de pago y metas. |
| **4. Dashboard & Métricas KPI** | ✅ Completado | Tivo Score, Safe-to-Spend, Runway Financiero, Cashflow Chart dinámico y Carousel. |
| **5. Finanzas & Transacciones** | ✅ Completado | CRUD Movimientos, Cuentas, Presupuestos por categoría, Metas de Ahorro y Calendario. |
| **6. Recordatorios & Pagos 1-Tap** | ✅ Completado | Gestión de servicios/tarjetas, modal de pago con débito y registro automático de gasto. |
| **7. Tivo Academy & Hábitos** | ✅ Completado | Píldoras financieras, Retos de ahorro, Enfriador de impulsos y Calculadora de interés. |
| **8. Multi-Moneda e Internacionalización**| ✅ Completado | Formateo dinámico (COP, USD, EUR) y soporte bilingüe completo (Español / Inglés). |
| **9. Persistencia & Datos** | ✅ Completado | Almacenamiento local con `SharedPreferences` y arquitectura Cloud lista. |
| **10. Pruebas Unitarias & Widgets** | ✅ Completado | Suite de tests automatizados para lógica financiera, sincronización y UI. |

---

## 🧩 Detalle del Checklist por Módulos

### 1. 🎨 Sistema de Diseño, Tema y Marca
- [x] **Tema Glassmorphism Dark Mode:**
  - [x] Paleta de colores `TivoColors` (`bgDeepNavy`, `glassOverlay`, `accentElectricCyan`, `primaryIceBlue`, etc.).
  - [x] Componentes visuales reutilizables: `GlassCard`, `TivoButton`, `GlowingBadge`, `TivoScoreGauge`.
- [x] **Branding & Logo:**
  - [x] Logo vectorial nativo `TivoLogo` sin fondos residuales ni artefactos visuales.
  - [x] Renderizado de logo 3D con desvanecimiento radial suave para pantallas de bienvenida.
  - [x] Iconos de lanzador (App Launcher Icons) para iOS y Android generados transparentes.
- [x] **Tipografía & Animaciones:**
  - [x] Integración de fuentes Google Fonts (*Plus Jakarta Sans / Inter*).
  - [x] Micro-animaciones fluidas con `flutter_animate`.

---

### 2. 🔐 Autenticación, Seguridad y Perfil
- [x] **Métodos de Inicio de Sesión:**
  - [x] Inicio de sesión con **Google** (`GoogleSignIn` + `FirebaseAuth`).
  - [x] Inicio de sesión con Correo Electrónico y Contraseña (con alternancia Registro/Login).
  - [x] Modo Invitado (*Continuar como invitado*) para funcionamiento 100% offline.
  - [x] Preparación de infraestructura para *Sign in with Apple*.
- [x] **Onboarding de Perfil Financiero:**
  - [x] Formulario inicial: Nombre, Salario mensual, Frecuencia de pago (Quincenal, Mensual, Semanal, Variable).
  - [x] Asignación de % de meta de ahorro sugerida y cuenta bancaria de recepción.
  - [x] Generación automática de saldo inicial y transacción de ingreso recurrente.
- [x] **Gestión de Perfil:**
  - [x] Modal de edición de perfil (`EditProfileModal`) para actualizar datos y metas en caliente.
  - [x] Proveedor de estado reactivo `ProfileProvider` persistido.
- [x] **Seguridad & Privacidad:**
  - [x] Autenticación Biométrica (Face ID / Touch ID / Huella) mediante `local_auth`.
  - [x] Bloqueo por PIN de 4 dígitos con cambiador interactivo de PIN en ajustes.
  - [x] Modo Privacidad (enmascaramiento de saldos monetarios con `••••••`).
  - [x] Auto-bloqueo configurable por inactividad.
- [x] **Cumplimiento App Store:**
  - [x] Opción de *Cerrar Sesión* segura.
  - [x] Flujo de *Eliminación Permanente de Cuenta y Datos* con diálogo de confirmación y borrado total.

---

### 3. 📊 Dashboard (Panel de Control Principal)
- [x] **Resumen Patrimonial:**
  - [x] Tarjeta de **Patrimonio Neto** con efecto resplandor dinámico (Activos - Pasivos).
  - [x] Indicador de salud financiera **Tivo Score** (0 a 100) en gauge interactivo.
- [x] **Tarjetas KPI Inteligentes:**
  - [x] `Safe-to-Spend`: Cálculo diario del monto seguro disponible para gastar.
  - [x] `Financial Runway`: Medición de meses de subsistencia ante pérdida de ingresos.
  - [x] Navegación directa con un toque hacia las secciones correspondientes desde cada KPI.
- [x] **Visualización de Flujo de Caja:**
  - [x] Gráfico comparativo de Ingresos vs. Gastos con `fl_chart`.
  - [x] Mini calendario interactivo de 7 días sincronizado con el gráfico.
- [x] **Carrusel de Billeteras (`WalletCarousel`):**
  - [x] Visualización de cuentas bancarias, efectivo y tarjetas de crédito (cupo disponible vs. total).
- [x] **Alertas y Accesos Rápidos:**
  - [x] Radar de suscripciones y próximos recibos a vencer (`UpcomingRemindersCard`).
  - [x] Píldora de tip financiero diario deslizable (`DailyTipCard`).
  - [x] Fila de acciones rápidas (`QuickActionsRow`).

---

### 4. 💸 Finanzas, Movimientos y Presupuestos
- [x] **Sub-pestañas integradas en Finanzas:**
  - [x] **Movimientos:**
    - [x] Filtros por tipo: *Todos, Gastos, Ingresos, Fijos*.
    - [x] Gráfico circular de distribución de gastos por categorías (`ExpenseChart`).
    - [x] Lista cronológica agrupada por fecha (Hoy, Ayer, fecha específica).
    - [x] Edición y eliminación de transacciones.
  - [x] **Cuentas e Instrumentos:**
    - [x] CRUD completo de cuentas corrientes, ahorros, billeteras y tarjetas de crédito.
    - [x] Indicador de utilización de crédito (%).
  - [x] **Presupuestos:**
    - [x] CRUD de presupuestos mensuales por categoría (Alimentación, Transporte, Ocio, etc.).
    - [x] Barra de progreso con cambio automático de color (Verde $\to$ Ámbar $\to$ Rojo).
  - [x] **Metas de Ahorro:**
    - [x] Creación y seguimiento de objetivos de ahorro (Monto meta vs. acumulado).
    - [x] Aportes manuales y sugerencia de cuotas periódicas.
  - [x] **Calendario Financiero:**
    - [x] Integración de `table_calendar` con marcadores visuales en días con movimientos o cortes.
- [x] **Registro Rápido de Movimientos (`AddTransactionModal`):**
  - [x] Botón flotante central (FAB) persistente en toda la navegación.
  - [x] Selección rápida de categoría, cuenta afectada, fecha y descripción.
  - [x] **Sincronización Bidireccional de Saldos:** Al crear, editar o borrar una transacción, el saldo de la cuenta asociada se recalcula automáticamente.

---

### 5. 🔔 Recordatorios y Automatización de Pagos
- [x] **Gestión de Pagos Fijos (`RemindersProvider`):**
  - [x] Registro y edición de recibos públicos, servicios, suscripciones y tarjetas de crédito.
  - [x] Alertas por proximidad de fecha de vencimiento.
- [x] **Pago 1-Tap (`PayReminderModal`):**
  - [x] Selección de la cuenta de débito/origen del dinero.
  - [x] Marcado automático del recordatorio como pagado.
  - [x] Creación automática de la transacción de gasto correspondiente en el historial.
  - [x] Descuento inmediato del saldo en la cuenta seleccionada.

---

### 6. 🎓 Tivo Academy & Hábitos Financieros
- [x] **Educación Financiera (`TipsAcademyScreen`):**
  - [x] Tarjetas de píldoras financieras categorizadas (Ahorro, Inversión, Deudas, Mentalidad).
- [x] **Retos de Ahorro:**
  - [x] Desafíos interactivos (Reto de 52 semanas, reto sin gastos hormiga, etc.).
- [x] **Enfriador de Impulsos (`ImpulseCoolerModal`):**
  - [x] Herramienta para pausar compras impulsivas y evaluar necesidad real vs. deseo.
- [x] **Calculadora de Interés Compuesto:**
  - [x] Simulador interactivo con capital inicial, aportes mensuales, tasa anual y plazo.
  - [x] Cálculo en tiempo real de rendimiento generado vs. capital aportado.

---

### 7. 🌍 Multi-Moneda e Internacionalización
- [x] **Gestor de Monedas (`CurrencyProvider` & `CurrencyFormatter`):**
  - [x] Soporte dinámico para Pesos Colombianos (`COP`), Dólares (`USD`) y Euros (`EUR`).
  - [x] Formato estándar con símbolo al inicio (`$ 1.500.000 COP`, `$ 1,200.00 USD`, `€ 1.200,00 EUR`).
  - [x] Formateador compacto para gráficos y tarjetas (`$ 1.5M`, `$ 450K`).
- [x] **Gestor de Idiomas (`LanguageProvider`):**
  - [x] Soporte para **Español (ES)** e **Inglés (EN)**.
  - [x] Diccionario reactivo centralizado con actualización instantánea en toda la interfaz sin reiniciar.

---

### 8. ⚙️ Ajustes y Datos
- [x] **Pantalla de Ajustes (`SettingsScreen`):**
  - [x] Tarjeta de perfil interactiva con acceso a edición.
  - [x] Selectores de moneda, idioma y seguridad.
  - [x] Estado de sincronización en la nube / Firebase.
  - [x] Exportación de datos y reseteo completo a fábrica (*Danger Zone*).

---

### 🧪 9. Pruebas Automatizadas y Calidad de Código
- [x] **Suite de Tests Unitarios (`test/financial_metrics_test.dart`):**
  - [x] Test de formateo de moneda con símbolo inicial.
  - [x] Test de cambio dinámico entre monedas (USD, EUR, COP).
  - [x] Test de formateo compacto de cifras.
  - [x] Test de cálculo de utilización de crédito en tarjetas.
  - [x] Test de persistencia de preferencias en `StorageService`.
  - [x] Test del diccionario bilingüe de traducciones.
  - [x] Test de sincronización de saldos de cuentas en Create/Update/Delete de transacciones.
  - [x] Test de flujo 1-Tap Pay de recordatorios (marcado, débito de cuenta y registro de gasto).
- [x] **Suite de Tests de Widgets (`test/widget_test.dart`):**
  - [x] Test de carga inicial de aplicación, branding y bienvenida.

---

## 🗺️ Próximos Pasos y Hoja de Ruta Futura (Roadmap)

### 🔹 Corto Plazo (Sprint Inmediato)
- [ ] **Sincronización Cloud Firestore en Segundo Plano:**
  - [ ] Colecciones de usuario aisladas (`users/{uid}/accounts`, `users/{uid}/transactions`, etc.).
  - [ ] Listener reactivo con fallback offline transparente.
- [ ] **Exportación de Reportes:**
  - [ ] Generación y descarga de extractos mensuales en formato **PDF** con diseño ejecutivo.
  - [ ] Exportación de movimientos en formato **CSV / Excel**.

### 🔹 Mediano Plazo
- [ ] **Notificaciones Push Locales y Remotas:**
  - [ ] Alertas 24h y 2h antes de vencimiento de recordatorios y fechas de corte con `flutter_local_notifications`.
  - [ ] Resumen semanal de presupuesto disponible.
- [ ] **Widgets de Pantalla de Inicio (Home Screen Widgets):**
  - [ ] Widget de iOS (WidgetKit) y Android (Glance/AppWidgets) para visualizar *Safe-to-Spend* y *Patrimonio Neto*.
- [ ] **Reconocimiento Óptico de Facturas (OCR):**
  - [ ] Escaneo de recibos físicos con cámara mediante ML Kit para auto-rellenar transacciones.

### 🔹 Largo Plazo
- [ ] **Open Banking / Conexión Bancaria:**
  - [ ] Integración opcional mediante APIs financieras para sincronización automática de movimientos bancarios.
- [ ] **Asistente Financiero IA Integrado:**
  - [ ] Consultas en lenguaje natural (*"¿Cuánto he gastado este mes en restaurantes?"*, *"¿Cómo optimizo mis deudas?"*).
