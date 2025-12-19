# SaveFood - Save Food, Save Planet

A Flutter-based food waste reduction application that connects restaurants with customers to reduce food waste and save money.

## 🌱 About SaveFood

SaveFood is a comprehensive platform that helps reduce food waste by connecting restaurants with customers who want to purchase surplus food at discounted prices. The app features:

- **Food Discovery**: Find discounted food items from nearby restaurants
- **Real-time Tracking**: Track your orders from purchase to delivery
- **User Profiles**: Complete profile management with Google Sign-In
- **Admin Panel**: Comprehensive admin dashboard for managing restaurants, orders, and users
- **Backend API**: Full-featured Node.js Express backend with MySQL database

## 🚀 Features

### User App
- 🔐 Authentication (Email/Password & Google Sign-In)
- 🍕 Browse food items from nearby restaurants
- 🛒 Shopping cart and checkout
- 📦 Order tracking and history
- 👤 User profile management
- 💳 Payment integration ready
- 📍 Location-based search

### Admin Panel
- 📊 Dashboard with analytics
- 🏪 Restaurant management
- 📋 Order management
- 👥 User management
- 🎫 Coupon management
- 📈 Analytics and reporting

### Backend
- 🔒 JWT authentication
- 🗄️ MySQL database with migrations
- 📡 RESTful API endpoints
- 🔐 Role-based access control (Admin/User)
- 📦 Delivery tracking system
- 🔔 Notification system

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Riverpod** - State management
- **Google Sign-In** - Authentication
- **Material Design 3** - UI components

### Backend
- **Node.js** - Runtime environment
- **Express** - Web framework
- **MySQL** - Database
- **JWT** - Authentication tokens
- **bcryptjs** - Password hashing

### Admin Panel
- **Flutter Web** - Web admin interface
- **DataTable2** - Data tables
- **Riverpod** - State management

## 📁 Project Structure

```
Project1/
├── lib/                    # Main Flutter app
│   ├── core/              # Core utilities, theme, constants
│   ├── data/              # Data models and repositories
│   ├── presentation/      # UI screens and widgets
│   └── services/          # API and authentication services
├── admin_web/             # Flutter web admin panel
├── backend/               # Node.js Express backend
│   ├── config/           # Database configuration
│   ├── migrations/      # Database migrations
│   ├── models/          # Data models
│   ├── routes/          # API routes
│   └── middleware/      # Auth and admin middleware
└── web/                  # Web configuration
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Node.js (v14 or higher)
- MySQL (v8.0 or higher)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/virajrajguru67-png/Food-Waste-Reducer-Project.git
   cd Food-Waste-Reducer-Project
   ```

2. **Setup Flutter App**
   ```bash
   flutter pub get
   ```

3. **Setup Backend**
   ```bash
   cd backend
   npm install
   ```

4. **Configure Environment Variables**
   - Copy `backend/.env.example` to `backend/.env`
   - Update database credentials and JWT secret

5. **Run Database Migrations**
   ```bash
   cd backend
   npm run migrate
   ```

6. **Start Backend Server**
   ```bash
   cd backend
   npm start
   ```

7. **Run Flutter App**
   ```bash
   flutter run
   ```

8. **Run Admin Panel**
   ```bash
   cd admin_web
   flutter run -d chrome
   ```

## 🔧 Configuration

### Google Sign-In Setup
1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sign-In API
3. Create OAuth 2.0 credentials
4. Add authorized redirect URIs:
   - `http://localhost:3000/`
   - `http://localhost:8080/`
   - `http://localhost:5000/`
5. Update `web/index.html` with your client ID

### Database Setup
1. Create a MySQL database
2. Update `backend/.env` with your database credentials
3. Run migrations: `npm run migrate`

## 📱 Screenshots

*Add screenshots of your app here*

## 📝 API Documentation

See [backend/CRUD_API_DOCUMENTATION.md](backend/CRUD_API_DOCUMENTATION.md) for complete API documentation.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Viraj Rajguru**
- GitHub: [@virajrajguru67-png](https://github.com/virajrajguru67-png)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source contributors

---

**SaveFood** - Reducing food waste, one meal at a time! 🌱
