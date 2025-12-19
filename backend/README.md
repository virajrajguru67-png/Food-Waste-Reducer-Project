# SaveFood Backend API

Node.js Express backend with MySQL database for SaveFood app.

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment:**
   - Copy `.env.example` to `.env`
   - Update database credentials in `.env`

3. **Run migrations:**
   ```bash
   npm run migrate
   ```

4. **Start server:**
   ```bash
   npm start
   # or for development with auto-reload:
   npm run dev
   ```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/google` - Google Sign-In
- `GET /api/auth/me` - Get current user

### Health Check

- `GET /health` - Server health check

## Database Schema

### Users Table
- `id` - Primary key
- `name` - User name
- `email` - Unique email
- `password` - Hashed password
- `phone` - Phone number (optional)
- `google_id` - Google ID (for Google Sign-In)
- `google_email` - Google email
- `created_at` - Creation timestamp
- `updated_at` - Update timestamp

