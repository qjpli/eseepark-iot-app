# eSEEPark IoT App

## **Description**  
eSEEPark is an innovative parking solution designed to help drivers locate available parking spots in real time. It integrates IoT technology with cloud computing to provide a seamless parking experience for both users and parking administrators.  

## **Technologies Used**  
- **Flutter & Dart** – Cross-platform mobile app development.  
- **IoT (ESP32, Arduino, HC-SR04 sensors, LED indicators, Servo motor)** – Monitors parking slot occupancy and automates entry/exit gates.  
- **Cloud Computing (Supabase)** – Handles database management and authentication.  
- *(Optional Add-ons: ESP32-CAM for QR scanning, enhanced automation features)*  

## **Features**  
✅ **Real-time Parking Slot Availability** – View available, occupied, and under-maintenance slots.  
✅ **Slot Filtering** – Filter by PWD, EV charging, covered parking, etc.  
✅ **Reservation System** – Reserve slots in advance and validate via QR code.  
✅ **Favorite Parking Locations** – Save frequently visited parking areas.  
✅ **Occupied Slot Timer** – Tracks how long a slot has been occupied.  
✅ **Parking History** – View and export past bookings and payments.  

### **Potential Add-ons (Future Enhancements)**  
➕ **QR Code System (Optional)** – Scan QR codes for quick access to parking information.  
➕ **ESP32-CAM Integration (Optional)** – Use ESP32-CAM to scan QR codes for automated entry

## Installation Instructions
1. Clone the repository:
   ```sh
   git clone https://github.com/qjpli/eseepark-iot-app.git
   cd eseepark-iot-app
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the application:
   ```sh
   flutter run
   ```

## Setup
### IoT Device Setup
- Connect **HC-SR04 ultrasonic sensors** to **ESP32** to detect car presence.
- Integrate **LED indicators** to show slot status.
- Use **Servo motors** for entry/exit gate automation.
- Program the ESP32 using **Arduino IDE**.

### Cloud Setup (Supabase)
1. Create a **Supabase** account and project.
2. Set up database tables for parking slots, reservations, user authentication, and others.
3. Configure API keys and environment variables in Flutter.

## Contribution
Feel free to contribute by submitting pull requests or opening issues.

---

For any inquiries, contact us at **esepark.system@gmail.com** 🚗💨
