Antigravity Prompt for Artisan Marketplace App
Project Title:
SkillLink – On-Demand Artisan Service Marketplace

🧠 Core Objective
Build a full-stack platform that connects users (customers) with skilled artisans (plumbers, electricians, carpenters, cleaners, etc.). The system should include:
    • Mobile app (Flutter) for users & artisans 
    • Backend API (PHP + MySQLi, MVC architecture) 
    • Web-based Admin Panel (PHP MVC) 
    • Integration-ready UI from Stitch AI 

📱 Frontend (Flutter Mobile App)
Use the UI design generated from Stitch AI and convert it into a functional Flutter app.
Key Screens:
    1. Onboarding / Splash Screen 
    2. User Authentication 
        ◦ Sign up / Login (Email, Phone, OTP) 
    3. Home Screen 
        ◦ Search artisans 
        ◦ Categories (Plumbing, Electrical, Cleaning, etc.) 
        ◦ Featured artisans 
    4. Artisan Listing Page 
        ◦ Filter by location, rating, price 
    5. Artisan Profile 
        ◦ Bio, skills, ratings, reviews, portfolio 
        ◦ Book service button 
    6. Booking System 
        ◦ Select date/time 
        ◦ Service description 
    7. Chat System 
        ◦ Real-time messaging between user & artisan 
    8. Payments 
        ◦ Wallet / card integration 
    9. User Dashboard 
        ◦ Bookings history 
        ◦ Saved artisans 
    10. Artisan Dashboard 
    • Job requests 
    • Earnings 
    • Availability toggle 
    11. Notifications 
    12. Settings/Profile 

⚙️ Backend (PHP + MySQLi using MVC Architecture)
Build a scalable RESTful API using pure PHP (no frameworks) structured in MVC:
Structure:
    • Models: Handle database logic (MySQLi) 
    • Views: Minimal (API responses in JSON) 
    • Controllers: Handle request logic 
Core Modules:
    1. Authentication System 
        ◦ JWT-based authentication 
        ◦ Role-based access (User, Artisan, Admin) 
    2. User Management 
        ◦ Register/Login 
        ◦ Profile update 
    3. Artisan Management 
        ◦ Skill/category assignment 
        ◦ Verification system 
        ◦ Availability status 
    4. Service & Category Management 
        ◦ CRUD for service categories 
    5. Booking System 
        ◦ Create, accept, reject, complete bookings 
        ◦ Status tracking 
    6. Messaging System 
        ◦ Real-time or near real-time chat (API-based) 
    7. Payment Integration 
        ◦ Payment gateway APIs (Paystack/Flutterwave) 
    8. Ratings & Reviews 
        ◦ Users rate artisans after service 
    9. Notifications 
        ◦ Push notifications (Firebase integration) 
    10. Location Services 
    • Geo-based artisan matching 

🛠️ Admin Panel (PHP MVC Web Dashboard)
Responsive web dashboard for system management.
Features:
    • Dashboard analytics (users, bookings, revenue) 
    • Manage users & artisans 
    • Approve/reject artisan registrations 
    • Manage categories/services 
    • View all bookings 
    • Handle disputes 
    • Payment tracking 
    • CMS (optional: blog, announcements) 

🎨 UI Integration (From Stitch AI)
    • Convert Stitch AI exported designs into Flutter widgets 
    • Maintain: 
        ◦ Consistent spacing, typography, and colors 
        ◦ Responsive layouts 
    • Optimize for: 
        ◦ Performance 
        ◦ Reusability (custom widgets/components) 

🔌 API Specification
    • RESTful endpoints 
    • JSON responses 
    • Secure endpoints with JWT 
    • Versioned API (e.g., /api/v1/) 

🧱 Database Design (MySQL)
Core tables:
    • users 
    • artisans 
    • categories 
    • services 
    • bookings 
    • payments 
    • reviews 
    • messages 
    • notifications 

🔐 Security Requirements
    • Password hashing (bcrypt) 
    • Input validation & sanitization 
    • Secure API authentication (JWT) 
    • Protection against SQL injection (prepared statements) 

⚡ Performance & Scalability
    • Optimized queries 
    • Pagination for listings 
    • Caching (optional) 
    • Modular MVC structure 

📦 Deployment Considerations
    • Backend: Apache/Nginx (PHP server) 
    • Database: MySQL 
    • Mobile app: Android & iOS builds 
    • Cloud storage for images (optional) 

🎯 Expected Output from Antigravity
    • Fully structured PHP MVC backend 
    • RESTful API endpoints 
    • Admin dashboard (web) 
    • Flutter app integrated with Stitch UI 
    • Database schema (SQL file) 
    • API documentation 

💡 Optional Enhancements
    • In-app voice search for artisans 
    • AI-based artisan recommendation 
    • Subscription model for artisans 
    • Service bidding system
