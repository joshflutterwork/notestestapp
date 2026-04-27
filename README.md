# Notes App Project

This project is a modern, full-stack notes application. The development of this project was assisted by **GLM AI**, which was used to help review the backend architecture, design API requirements, and assist the frontend with widgeting, styling, and establishing a Clean Architecture file structure.

## Key Features
- 🔐 **Secure User Authentication**: Login and Registration flow using JWT.
- 📝 **Notes Management**: Create, Read, Update, and Delete (CRUD) notes.
- 🎨 **Modern Interface**: Clean, intuitive UI/UX with Clean Architecture.
- 📖 **API Documentation**: Interactive Swagger UI provided for backend endpoints.

## Prerequisites

### Backend
- Node.js (v18 or higher)
- npm or yarn
- Docker and Docker Compose (for PostgreSQL)

### Frontend
- Flutter SDK (v3.41.4)
- Dart SDK (v3.11.1)
- Android Studio / Xcode (for mobile development)
- Android SDK / iOS SDK
- FVM (Flutter Version Management) - optional but recommended

## API Documentation (Swagger)
Once the backend server is running, the interactive Swagger API documentation can be accessed at:
- **[http://localhost:3000/api/docs](http://localhost:3000/api/docs)**

## API Endpoints Quick Reference

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register new user | No |
| POST | `/api/auth/login` | Login user | No |
| GET | `/api/notes` | Get all user notes | Yes |
| GET | `/api/notes/:id` | Get specific note | Yes |
| POST | `/api/notes` | Create note | Yes |
| PUT | `/api/notes/:id` | Update note | Yes |
| DELETE | `/api/notes/:id` | Delete note | Yes |

---

## 1. Initial Project Requirements (Tech Stack)

### Backend (NestJS)
- **Framework**: NestJS v11.1.19 (Node.js)
- **Database & ORM**: PostgreSQL with Prisma ORM
- **Authentication**: Passport & JWT (with `bcrypt` for password hashing)
- **Validation**: `class-validator` and `class-transformer`

### Frontend (Flutter)
- **Framework**: Flutter SDK v3.41.4 (Dart v3.11.1)
- **State Management**: BLoC / Cubit (`flutter_bloc`, `equatable`)
- **Networking**: HTTP Library (`http`)
- **Local Security**: `flutter_secure_storage` for token storage
- **Dependency Injection**: `get_it`

---

## 2. How to Run the Project

### Setup Backend
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables:
   
   Create a `.env` file in the backend directory with the following configuration:
   ```env
   DATABASE_URL="postgresql://postgres:postgres@localhost:5432/notesapp?schema=public"
   JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
   PORT=3000
   ```
   
   **Note**: For production, replace the `JWT_SECRET` with a secure random string.
4. Set up the database (Migration & Seeding):
   ```bash
   npm run db:setup
   # Or manually: npm run prisma:migrate && npm run prisma:seed
   ```
5. Start the backend server:
   ```bash
   npm run start:dev
   ```
   *(The backend typically runs on `http://localhost:3000` by default)*

### Setup Frontend
*(Optional but Recommended)* This project supports **FVM (Flutter Version Management)**. If you are using it, run `fvm install` in the frontend directory before proceeding.
To configure VSCode to use the FVM SDK, add the following to your workspace's `.vscode/settings.json` file:
```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "search.exclude": {
    "**/.fvm": true
  }
}
```

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Fetch required packages (prepend `fvm` if using FVM, e.g., `fvm flutter pub get`):
   ```bash
   flutter pub get
   ```
3. If there is code generation (e.g., JSON Serializable or mock objects), run the build runner:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the application on an emulator or a physical device:
   ```bash
   flutter run
   ```

---

## 3. Project File Structure

### Backend (`/backend/src`)
The backend uses a modular architecture provided by NestJS:
```text
backend/
├── prisma/               # Database schema configurations and Seeder scripts
├── src/
│   ├── auth/             # Controller, Service, and Strategy for JWT Login/Register
│   ├── notes/            # CRUD implementations for the Notes feature
│   ├── users/            # Data retrieval & details for user profiles
│   ├── prisma/           # Prisma ORM connection service configuration
│   ├── app.module.ts     # Main backend module
│   └── main.ts           # Server application entry point
└── test/                 # End-to-End (E2E) testing directory
```

### Frontend (`/frontend/lib`)
The frontend is built using Feature-Driven Clean Architecture:
```text
frontend/
├── lib/
│   ├── core/             # Core logic, helpers, and global UI widgets shared across features
│   ├── features/         # Main application features
│   │   ├── auth/         # Login/register flow (data, domain, and presentation layers)
│   │   └── notes/        # Notes list and detail views
│   └── main.dart         # Mobile application entry point
└── test/                 # Directory containing all unit and widget tests
```

## Database Schema

### User Model
- `id` (UUID, Primary Key)
- `email` (String, Unique)
- `password` (String, Hashed with Bcrypt)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

### Note Model
- `id` (UUID, Primary Key)
- `title` (String)
- `content` (String)
- `userId` (String, Foreign Key to User)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

---

## 4. Running Tests

### Backend
Open a terminal inside the `backend` directory and run:
- **Unit Tests**:
  ```bash
  npm run test
  ```
- **End-to-End (E2E) Tests**:
  ```bash
  npm run test:e2e
  ```

### Frontend
Open a terminal inside the `frontend` directory and run:
- **Run all Unit & Widget Tests**:
  ```bash
  flutter test
  ```

---

## Troubleshooting

### Backend Issues

#### Database Connection Issues
If you encounter database connection errors:
1. Ensure Docker is running: `docker ps`
2. Check if PostgreSQL container is running: `docker-compose ps`
3. Verify DATABASE_URL in `.env` matches your Docker configuration
4. Restart the PostgreSQL container: `docker-compose restart`

#### Port Already in Use
If port 3000 is already in use:
1. Change the PORT in `.env`
2. Or stop the process using port 3000

#### Prisma Client Issues
If you see TypeScript errors related to Prisma:
```bash
cd backend
npm run prisma:generate
```

### Frontend Issues

#### API Connection Issues
If the app can't connect to the API:
1. Verify the backend is running on `http://localhost:3000`
2. Check the API base URL in `lib/core/constants/api_constants.dart`
3. For Android emulator, use `http://10.0.2.2:3000`
4. For iOS simulator, use `http://localhost:3000`
5. For physical device, use your computer's IP address

#### Build Issues
If you encounter build errors:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run` again

#### Dependency Issues
If you have dependency conflicts:
1. Delete `pubspec.lock`
2. Run `flutter pub get`
3. If using build_runner, run `flutter pub run build_runner build --delete-conflicting-outputs`
