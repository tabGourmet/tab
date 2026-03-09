# TAB — Digital Restaurant Management

Plataforma digital para la gestión de restaurantes: menú digital, pedidos por mesa, panel de administración y métricas.

## Estructura del Proyecto

```
tab/
├── frontend/          ← App React (Vite + TypeScript)
│   ├── src/
│   │   ├── components/
│   │   │   ├── auth/        Login, Register, CreateRestaurant
│   │   │   ├── business/    AdminDashboard, AdminOrders, AdminMetrics
│   │   │   ├── customer/    CustomerApp, Menu, OrderSummary
│   │   │   └── common/      DateFilter, SubscriptionGate
│   │   ├── context/         AppContext, AuthContext
│   │   ├── services/        API client (api.ts)
│   │   ├── types/           TypeScript interfaces compartidas
│   │   └── App.tsx          Rutas principales
│   ├── package.json
│   └── vite.config.ts
│
├── backend/           ← API Express (TypeScript + Prisma)
│   ├── src/
│   │   ├── controllers/     Lógica de negocio por dominio
│   │   ├── routes/          Definición de endpoints
│   │   ├── middleware/      Auth, validación, error handling
│   │   ├── config/          DB, env, Supabase
│   │   ├── schemas/         Validación con Zod
│   │   └── services/        Servicios auxiliares
│   ├── prisma/              Schema y migraciones
│   ├── package.json
│   └── tsconfig.json
│
├── docs/              ← Documentación
│   └── FLUJO_APP.md         Guía de flujos y testing
│
├── package.json       ← Monorepo root (npm workspaces)
└── .env.example       ← Referencia de variables de entorno
```

## Requisitos

- **Node.js** >= 18
- **PostgreSQL** (o Supabase)

## Inicio Rápido

### 1. Instalar dependencias

```bash
# Desde la raíz — instala ambos workspaces
npm install
```

### 2. Configurar variables de entorno

```bash
# Frontend
cp frontend/.env.example frontend/.env   # o crear manualmente

# Backend
cp backend/.env.example backend/.env     # o crear manualmente
```

Ver `.env.example` en la raíz para referencia de todas las variables.

### 3. Preparar la base de datos

```bash
npm run db:push        # Sincronizar schema
npm run db:seed        # Cargar datos de prueba
```

### 4. Levantar los servidores

```bash
# Terminal 1 — Backend (puerto 3001)
npm run dev:backend

# Terminal 2 — Frontend (puerto 5173)
npm run dev:frontend
```

### 5. Acceder

| Flujo | URL |
|-------|-----|
| Login admin | `http://localhost:5173/login` |
| Registro dueño | `http://localhost:5173/register` |
| QR Mesa 1 (demo) | `http://localhost:5173/demo-restaurant/table/1` |
| Admin Dashboard | `http://localhost:5173/demo-restaurant/admin` |

**Credenciales de prueba**: `demo@gastrosplit.com` / `demo123`

## Scripts Disponibles (raíz)

| Script | Descripción |
|--------|-------------|
| `npm run dev:frontend` | Inicia Vite dev server |
| `npm run dev:backend` | Inicia Express con hot-reload |
| `npm run build:frontend` | Build de producción del frontend |
| `npm run build:backend` | Compila TypeScript del backend |
| `npm run db:generate` | Genera Prisma Client |
| `npm run db:migrate` | Ejecuta migraciones |
| `npm run db:push` | Push schema a la DB |
| `npm run db:seed` | Carga seed data |
| `npm run db:studio` | Abre Prisma Studio |
