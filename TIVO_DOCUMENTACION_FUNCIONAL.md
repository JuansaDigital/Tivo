# 📘 Documento de Especificación y Diseño Funcional

# **TIVO — Tu Asistente Inteligente de Finanzas Personales**

---

## 📑 1. Resumen Ejecutivo y Propósito

**Tivo** es una aplicación moderna y elegante de finanzas personales, gestión patrimonial y educación financiera. Su objetivo es transformar la forma en que los usuarios administran su dinero, pasando de hojas de cálculo complejas y aburridas a una experiencia visual interactiva, intuitiva y premium.

La aplicación combina el control diario de ingresos, gastos y costos con la proyección y seguimiento de instrumentos financieros (cuentas de ahorro, tarjetas de débito/crédito, e inversiones), complementado con un centro de aprendizaje financiero y un panel de alertas proactivas.

---

## 🎨 2. Sistema de Diseño Visual y Paleta de Colores

El estilo visual de **Tivo** está basado en **Glassmorphism (Efecto Vidrio Esmerilado)** con un enfoque Dark Mode premium.

### 🔵 Colores Principales (TivoColors)
- **Fondo General (`bgDeepNavy`):** `#070E22` (Azul Noche Profundo).
- **Glass Card (`glassOverlay`):** `#1A233A` con 40% de opacidad.
- **Bordes Glass:** Blanco con 10% de opacidad.

### ✨ Acentos y Gradientes
- **Primario (`primaryIceBlue`):** `#A3C2FA` (Para títulos y botones primarios).
- **Acento Activo (`accentElectricCyan`):** `#00F0FF` (Para selecciones, chips activos y gráficas destacadas).
- **Acento Secundario (`accentNeonCyan`):** `#00C2FF` (Botones de acción flotantes).
- **Acento Alternativo (`accentPurple`):** `#8B5CF6` (Para secciones de educación y recompensas).

### 🚦 Colores Semánticos / Estados
- **Ingresos/Positivo (`statusIncomeGreen`):** `#10B981` (Verde vibrante).
- **Fondo Suave Positivo (`statusIncomeGreenLight`):** `#D1FAE5` (Usado en porcentajes).
- **Gastos/Negativo (`statusExpenseRose`):** `#F43F5E` (Rojo rosáceo).
- **Fondo Suave Negativo (`statusExpenseRoseLight`):** `#FFE4E6`.
- **Advertencias/Cortes (`statusWarningAmber`):** `#F59E0B`.

### ✒️ Tipografía (Tivo Typography)
- **Familia:** `PlusJakartaSans` o `Inter`.
- **Pesos:**
  - `Bold (700-800)`: Títulos, Saldo Principal.
  - `Medium/SemiBold (500-600)`: Subtítulos, Categorías.
  - `Regular (400)`: Descripciones y fechas.

---

## 🧩 3. Arquitectura y Módulos de la Aplicación

La aplicación está dividida en cuatro (4) módulos principales accesibles desde una barra de navegación inferior (`BottomNavigationBar`).

### 📱 3.1. Dashboard (Panel Principal)
**Objetivo:** Dar una vista panorámica, rápida y motivadora del estado financiero actual.

**Componentes Clave:**
1. **Saludo y Perfil:** "Hola, [Nombre] 👋" con la foto de perfil del usuario (glass effect circular). Al hacer clic, abre las **Configuraciones** (Idioma, Moneda, Borrar datos).
2. **Tarjeta de Saldo Principal (Glassmorphism):**
   - Muestra el **Patrimonio Neto Total** (Suma de cuentas - deudas de tarjetas).
   - Botones rápidos: *Ingresar Dinero*, *Registrar Gasto*, *Transferir*.
3. **Distribución Rápida:**
   - Gráfico circular (`fl_chart`) simple o barra de progreso que muestre Ingresos vs Gastos del mes actual.
4. **Resumen de Cuentas:** Lista horizontal (`ListView.builder`) o Grid con las cuentas principales (Bancolombia, Nu, Efectivo) mostrando su saldo.
5. **Score Tivo (Tivo Score):** Un medidor (Gauge) de salud financiera de 0 a 100 basado en el porcentaje de ahorro y control de deudas.

---

### 💸 3.2. Finanzas (Movimientos, Cuentas, Presupuestos, Calendario)
**Objetivo:** Gestión detallada del dinero.

**Componentes Clave (Pestañas Superiores tipo `FilterChip`):**
1. **Movimientos (Historial):**
   - Filtros: *Todos, Gastos, Ingresos, Costos Fijos*.
   - Selector de fechas horizontal.
   - Gráfico de gastos por categorías (`ExpenseChart`).
   - Lista vertical agrupada por fechas (Hoy, Ayer, 12 Agosto, etc.). Cada ítem muestra icono de categoría, nombre, monto y hora.
   - Posibilidad de Editar o Eliminar.
2. **Cuentas (Instrumentos):**
   - Gestión (Crear, Editar, Eliminar) de Cuentas (Corriente, Ahorro, Efectivo).
   - Tarjetas de Crédito (con visualización de cupo total y disponible).
3. **Presupuestos:**
   - Gestión (Crear, Editar, Eliminar) de presupuestos por categoría (Ej. Comida, Transporte).
   - Barras de progreso visual que cambian de color (verde -> ámbar -> rojo) al acercarse al límite.
4. **Calendario:**
   - Calendario interactivo (`table_calendar`).
   - Muestra puntos de colores en los días con ingresos, gastos o fechas de corte.

---

### 🔔 3.3. Recordatorios y Metas
**Objetivo:** Automatizar pagos y fomentar el ahorro programado con CRUD completo.

**Componentes Clave:**
1. **Servicios & Pagos Fijos:**
   - Lista de recibos de luz, agua, internet, suscripciones (Netflix, Spotify).
   - Botón de "Pagar 1-Tap".
2. **Tarjetas & Deudas:**
   - Fechas de corte y límite de pago.
   - Simulación de "Pago Total" vs "Pago Mínimo".
3. **Metas & Ahorro Programado:**
   - Crear, Editar y Eliminar metas (Ej. "Fondo de Emergencia", "Viaje 2026").
   - Tarjetas con progreso en porcentaje y barra lineal, mostrando el monto objetivo vs acumulado, y aporte sugerido mensual.

---

### 🎓 3.4. Tips y Educación
**Objetivo:** Formar al usuario financieramente y motivarlo a alcanzar la independencia financiera.

**Componentes Clave:**
1. **Píldoras Financieras (Cards Deslizables):**
   - Tips diarios cortos (Ej. "Regla 50/30/20", "Evita los gastos hormiga").
2. **Retos de Ahorro:**
   - Retos personalizados que el usuario puede Crear, Editar y Eliminar (Ej. "Reto de 52 semanas").
3. **Calculadora Financiera:**
   - Simulador para calcular Interés Simple o Compuesto.
   - Personalizable: Monto inicial, aporte mensual, tasa de interés anual, y plazo en meses/años.
   - Gráfica o tabla que muestre cómo crece el dinero.

---

## ⚙️ 4. Configuraciones y Personalización

Al pulsar en el perfil desde el Dashboard, el usuario accederá a una pantalla de configuración (`SettingsScreen`) que debe incluir:
- **Idioma:** Selector de idioma (Español/Inglés) - *Requiere reinicio de app*.
- **Moneda:** Selector de moneda (COP, USD, EUR) - *Cambio reflejado globalmente*.
- **Seguridad:** Activar/Desactivar inicio de sesión por PIN o Biometría (`local_auth`).
- **Borrar Datos:** Un botón en zona de peligro para resetear toda la aplicación y empezar de cero.

---

## 🚀 5. Flujos Principales y Experiencia de Usuario (UX)

1. **Autenticación (Lock Screen):** Si la seguridad está activada, al abrir la app se pedirá PIN o huella digital (`LockScreen`).
2. **Onboarding (Futuro):** Pantallas introductorias explicando la propuesta de valor.
3. **Carga Rápida de Datos:** Botón FAB (Floating Action Button) persistente en el medio del BottomNavigationBar para añadir rápidamente un Gasto o Ingreso desde cualquier lugar.
4. **Formularios Dinámicos (Modales):** Uso intensivo de `showModalBottomSheet` con bordes redondeados y fondos de cristal para formularios de "Añadir Transacción" o "Crear Cuenta", evitando transiciones bruscas de pantalla completa.
5. **Micro-interacciones:** Animaciones suaves al cambiar de pestaña, tocar botones, y progreso fluido en barras y gráficas.
