-- Create delivery_tracking table
CREATE TABLE IF NOT EXISTS delivery_tracking (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  tracking_number VARCHAR(100) UNIQUE,
  status VARCHAR(50) DEFAULT 'pending',
  current_location JSON,
  estimated_delivery_time DATETIME,
  delivery_partner_id VARCHAR(100),
  external_api_tracking_id VARCHAR(255),
  status_history JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  INDEX idx_order_id (order_id),
  INDEX idx_tracking_number (tracking_number),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

