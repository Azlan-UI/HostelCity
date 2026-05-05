# Firestore Index Requirements

To ensure the hostel management system works correctly, you need to create the following composite indexes in the Firebase Console.

## How to Create Indexes
1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Select your project.
3.  Navigate to **Firestore Database** > **Indexes**.
4.  Click **Create Index**.

## Required Composite Indexes

### 1. Dues (Student View)
Used to show a student's payment history sorted by due date.
- **Collection ID**: `dues`
- **Fields**:
    - `studentId`: Ascending
    - `dueDate`: Descending
- **Query Scope**: Collection

### 2. Dues (Admin View)
Used to see all dues for a hostel sorted by due date.
- **Collection ID**: `dues`
- **Fields**:
    - `hostelId`: Ascending
    - `dueDate`: Descending
- **Query Scope**: Collection

### 3. Dues (Admin Overdue Filtering)
Used to filter overdue dues in a specific hostel.
- **Collection ID**: `dues`
- **Fields**:
    - `hostelId`: Ascending
    - `status`: Ascending
    - `dueDate`: Descending
- **Query Scope**: Collection

### 4. Bookings (Student History)
Used to display the list of bookings for a student.
- **Collection ID**: `bookings`
- **Fields**:
    - `studentId`: Ascending
    - `createdAt`: Descending
- **Query Scope**: Collection

### 5. Residents (Admin Filtering)
Used to see active residents in a hostel.
- **Collection ID**: `residents`
- **Fields**:
    - `hostelId`: Ascending
    - `isActive`: Ascending
- **Query Scope**: Collection

> [!TIP]
> If you encounter a "failed-precondition" error in the logs, it usually contains a direct link to create the missing index automatically.
