# Notes App Project

This project is a modern, full-stack notes application. The development of this project was assisted by **GLM AI**, which was used to help review the backend architecture, design API requirements, and assist the frontend with widgeting, styling, and establishing a Clean Architecture file structure.

## Key Features
- 🔐 **Secure User Authentication**: Login and Registration flow using JWT.
- 📝 **Notes Management**: Create, Read, Update, and Delete (CRUD) notes.
- 🎨 **Modern Interface**: Clean, intuitive UI/UX with Clean Architecture.
- 📖 **API Documentation**: Interactive Swagger UI provided for backend endpoints.

## API Documentation (Swagger)
Once the backend server is running, the interactive Swagger API documentation can be accessed at:
- **[http://localhost:3000/api/docs](http://localhost:3000/api/docs)**

---

## 1. Initial Project Requirements (Tech Stack)

### Backend (NestJS)
- **Framework**: NestJS (Node.js)
- **Database & ORM**: PostgreSQL with Prisma ORM
- **Authentication**: Passport & JWT (with `bcrypt` for password hashing)
- **Validation**: `class-validator` and `class-transformer`

### Frontend (Flutter)
- **Framework**: Flutter SDK (Dart)
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
3. Ensure you have your environment variables set up (in a `.env` file) with the correct PostgreSQL database credentials.
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
