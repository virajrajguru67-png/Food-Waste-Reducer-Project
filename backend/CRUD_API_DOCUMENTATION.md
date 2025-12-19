# CRUD API Documentation

This document lists all available CRUD operations for the SaveFood backend API.

## Base URL
```
http://localhost:5000/api
```

## Authentication
Most endpoints require authentication. Include the JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

---

## 1. Users (Auth)

### Register User
- **POST** `/auth/register`
- **Body**: `{ name, email, password, phone? }`
- **Response**: `{ success, data: { user, token } }`

### Login
- **POST** `/auth/login`
- **Body**: `{ email, password }`
- **Response**: `{ success, data: { user, token } }`

### Google Sign-In
- **POST** `/auth/google`
- **Body**: `{ googleId, email, name?, photoUrl? }`
- **Response**: `{ success, data: { user, token } }`

### Get Current User
- **GET** `/auth/me`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { user } }`

### Update Profile
- **PUT** `/auth/profile`
- **Headers**: `Authorization: Bearer <token>`
- **Body**: `{ userId, phone? }`
- **Response**: `{ success, data: { user } }`

---

## 2. Restaurants

### Get All Restaurants
- **GET** `/restaurants`
- **Query Params**: `status?`, `verified?`, `category?`, `search?`, `limit?`, `offset?`
- **Response**: `{ success, data: [restaurants] }`

### Get Restaurant by ID
- **GET** `/restaurants/:id`
- **Response**: `{ success, data: { restaurant } }`

### Create Restaurant
- **POST** `/restaurants`
- **Headers**: `Authorization: Bearer <token>` (Admin or Restaurant Owner)
- **Body**: `{ name, description?, category?, address?, latitude?, longitude?, phone?, email?, images?, operatingHours?, commissionRate? }`
- **Response**: `{ success, data: { restaurant } }`

### Update Restaurant
- **PUT** `/restaurants/:id`
- **Headers**: `Authorization: Bearer <token>` (Owner or Admin)
- **Body**: `{ name?, description?, category?, address?, latitude?, longitude?, phone?, email?, images?, operatingHours?, verified?, status?, commissionRate? }`
- **Response**: `{ success, data: { restaurant } }`

### Delete Restaurant
- **DELETE** `/restaurants/:id`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Response**: `{ success, message }`

### Get Restaurants by Owner
- **GET** `/restaurants/owner/:ownerId`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: [restaurants] }`

---

## 3. Food Items

### Get All Food Items
- **GET** `/food-items`
- **Query Params**: `restaurantId?`, `status?`, `category?`, `search?`, `limit?`, `offset?`
- **Response**: `{ success, data: [foodItems] }`

### Get Food Item by ID
- **GET** `/food-items/:id`
- **Response**: `{ success, data: { foodItem } }`

### Get Food Items by Restaurant
- **GET** `/food-items/restaurant/:restaurantId`
- **Query Params**: `status?`, `category?`, `search?`
- **Response**: `{ success, data: [foodItems] }`

### Create Food Item
- **POST** `/food-items`
- **Headers**: `Authorization: Bearer <token>` (Restaurant Owner or Admin)
- **Body**: `{ restaurantId, name, description?, category?, images?, originalPrice, discountedPrice, quantityAvailable?, expiryTime?, pickupTimeWindow?, ingredients?, allergens?, dietaryInfo? }`
- **Response**: `{ success, data: { foodItem } }`

### Update Food Item
- **PUT** `/food-items/:id`
- **Headers**: `Authorization: Bearer <token>` (Owner or Admin)
- **Body**: `{ name?, description?, category?, images?, originalPrice?, discountedPrice?, quantityAvailable?, expiryTime?, pickupTimeWindow?, ingredients?, allergens?, dietaryInfo?, status? }`
- **Response**: `{ success, data: { foodItem } }`

### Delete Food Item
- **DELETE** `/food-items/:id`
- **Headers**: `Authorization: Bearer <token>` (Owner or Admin)
- **Response**: `{ success, message }`

---

## 4. Orders

### Get All Orders
- **GET** `/orders`
- **Headers**: `Authorization: Bearer <token>`
- **Query Params**: `status?`, `paymentStatus?`, `limit?`, `offset?`
- **Response**: `{ success, data: [orders] }`

### Get Order by ID
- **GET** `/orders/:id`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { order } }`

### Create Order
- **POST** `/orders`
- **Headers**: `Authorization: Bearer <token>`
- **Body**: `{ restaurantId, items, totalAmount, discountAmount?, couponId?, finalAmount, paymentMethod?, address?, notes? }`
- **Response**: `{ success, data: { order } }`

### Update Order Status
- **PUT** `/orders/:id/status`
- **Headers**: `Authorization: Bearer <token>` (Restaurant Owner or Admin)
- **Body**: `{ status }`
- **Response**: `{ success, data: { order } }`

### Cancel Order
- **POST** `/orders/:id/cancel`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { order } }`

### Update Payment Status
- **PUT** `/orders/:id/payment`
- **Headers**: `Authorization: Bearer <token>`
- **Body**: `{ paymentStatus }`
- **Response**: `{ success, data: { order } }`

---

## 5. Coupons

### Get All Coupons
- **GET** `/coupons`
- **Query Params**: `status?`, `restaurantId?`, `limit?`
- **Response**: `{ success, data: [coupons] }`

### Get Coupon by ID
- **GET** `/coupons/:id`
- **Response**: `{ success, data: { coupon } }`

### Validate Coupon Code
- **GET** `/coupons/:code/validate`
- **Query Params**: `orderAmount`, `restaurantId?`
- **Response**: `{ success, data: { coupon, discount } }`

### Create Coupon
- **POST** `/coupons`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Body**: `{ code, type, value, minOrderAmount?, maxDiscount?, validFrom, validUntil, usageLimit?, restaurantId? }`
- **Response**: `{ success, data: { coupon } }`

### Update Coupon
- **PUT** `/coupons/:id`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Body**: `{ code?, type?, value?, minOrderAmount?, maxDiscount?, validFrom?, validUntil?, usageLimit?, restaurantId?, status? }`
- **Response**: `{ success, data: { coupon } }`

### Delete Coupon
- **DELETE** `/coupons/:id`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Response**: `{ success, message }`

---

## 6. Reviews

### Get All Reviews
- **GET** `/reviews`
- **Query Params**: `restaurantId?`, `rating?`, `limit?`
- **Response**: `{ success, data: [reviews] }`

### Get Reviews by Restaurant
- **GET** `/reviews/restaurant/:restaurantId`
- **Query Params**: `rating?`, `limit?`
- **Response**: `{ success, data: [reviews] }`

### Get Review by ID
- **GET** `/reviews/:id`
- **Response**: `{ success, data: { review } }`

### Create Review
- **POST** `/reviews`
- **Headers**: `Authorization: Bearer <token>`
- **Body**: `{ restaurantId, orderId?, rating, comment?, images? }`
- **Response**: `{ success, data: { review } }`

### Update Review
- **PUT** `/reviews/:id`
- **Headers**: `Authorization: Bearer <token>` (Author or Admin)
- **Body**: `{ rating?, comment?, images? }`
- **Response**: `{ success, data: { review } }`

### Mark Review as Helpful
- **POST** `/reviews/:id/helpful`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { review } }`

### Delete Review
- **DELETE** `/reviews/:id`
- **Headers**: `Authorization: Bearer <token>` (Author or Admin)
- **Response**: `{ success, message }`

---

## 7. Delivery Tracking

### Get Delivery Status by Order ID
- **GET** `/delivery/:orderId`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { tracking } }`

### Track by Tracking Number
- **GET** `/delivery/track/:trackingNumber`
- **Response**: `{ success, data: { tracking } }`

### Update Delivery Status
- **POST** `/delivery/:orderId/update`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Body**: `{ status, currentLocation?, estimatedDeliveryTime? }`
- **Response**: `{ success, data: { tracking } }`

### Webhook for External Delivery API
- **POST** `/delivery/:orderId/webhook`
- **Body**: `{ status, location?, estimatedDeliveryTime? }`
- **Response**: `{ success, message }`

### Get All Active Deliveries
- **GET** `/delivery`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `status?`, `limit?`
- **Response**: `{ success, data: [deliveries] }`

---

## 8. User Addresses

### Get All Addresses
- **GET** `/addresses`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: [addresses] }`

### Get Default Address
- **GET** `/addresses/default`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { address } }`

### Get Address by ID
- **GET** `/addresses/:id`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { address } }`

### Create Address
- **POST** `/addresses`
- **Headers**: `Authorization: Bearer <token>`
- **Body**: `{ label, addressLine1, addressLine2?, city, state?, postalCode?, country?, latitude?, longitude?, isDefault? }`
- **Response**: `{ success, data: { address } }`

### Update Address
- **PUT** `/addresses/:id`
- **Headers**: `Authorization: Bearer <token>`
- **Body**: `{ label?, addressLine1?, addressLine2?, city?, state?, postalCode?, country?, latitude?, longitude?, isDefault? }`
- **Response**: `{ success, data: { address } }`

### Delete Address
- **DELETE** `/addresses/:id`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, message }`

---

## 9. Notifications

### Get All Notifications
- **GET** `/notifications`
- **Headers**: `Authorization: Bearer <token>`
- **Query Params**: `read?`, `type?`, `limit?`
- **Response**: `{ success, data: [notifications] }`

### Get Unread Count
- **GET** `/notifications/unread-count`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { count } }`

### Get Notification by ID
- **GET** `/notifications/:id`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { notification } }`

### Mark Notification as Read
- **PUT** `/notifications/:id/read`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, data: { notification } }`

### Mark All Notifications as Read
- **PUT** `/notifications/read-all`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, message }`

### Delete Notification
- **DELETE** `/notifications/:id`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, message }`

### Delete All Notifications
- **DELETE** `/notifications`
- **Headers**: `Authorization: Bearer <token>`
- **Response**: `{ success, message }`

---

## 10. Admin Endpoints

### Get Dashboard Stats
- **GET** `/admin/dashboard`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `dateFrom?`, `dateTo?`
- **Response**: `{ success, data: { stats } }`

### Get All Users
- **GET** `/admin/users`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `role?`, `search?`, `limit?`, `offset?`
- **Response**: `{ success, data: [users] }`

### Get All Restaurants
- **GET** `/admin/restaurants`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `status?`, `verified?`, `search?`, `limit?`, `offset?`
- **Response**: `{ success, data: [restaurants] }`

### Get All Orders
- **GET** `/admin/orders`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `status?`, `paymentStatus?`, `limit?`, `offset?`
- **Response**: `{ success, data: [orders] }`

### Update User Role
- **PUT** `/admin/users/:id/role`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Body**: `{ role }`
- **Response**: `{ success, data: { user } }`

### Verify/Unverify Restaurant
- **PUT** `/admin/restaurants/:id/verify`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Body**: `{ verified }`
- **Response**: `{ success, data: { restaurant } }`

---

## 11. Analytics

### Create Analytics Event
- **POST** `/analytics`
- **Headers**: `Authorization: Bearer <token>`
- **Body**: `{ eventType, restaurantId?, orderId?, data? }`
- **Response**: `{ success, data: { id } }`

### Get Dashboard Stats
- **GET** `/analytics/dashboard`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `dateFrom?`, `dateTo?`
- **Response**: `{ success, data: { stats } }`

### Get Revenue Chart
- **GET** `/analytics/revenue`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `dateFrom?`, `dateTo?`, `groupBy?` (day/month/year)
- **Response**: `{ success, data: [chartData] }`

### Get User Growth Chart
- **GET** `/analytics/user-growth`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `dateFrom?`, `dateTo?`, `groupBy?` (day/month/year)
- **Response**: `{ success, data: [chartData] }`

### Get Event Counts
- **GET** `/analytics/events/:eventType`
- **Headers**: `Authorization: Bearer <token>` (Admin only)
- **Query Params**: `dateFrom?`, `dateTo?`
- **Response**: `{ success, data: { eventType, count } }`

---

## Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## Notes

- All timestamps are in ISO 8601 format
- All monetary values are in Indian Rupees (₹)
- JSON fields (address, images, etc.) should be sent as objects/arrays
- Pagination uses `limit` and `offset` query parameters
- Filtering and searching are available on most list endpoints

