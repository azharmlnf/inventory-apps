#### 3.4.3 Diagram ERD (Konseptual untuk Appwrite)
*Catatan: Ini adalah representasi konseptual. Di Appwrite, relasi diimplementasikan melalui ID yang disimpan, dan keamanan diatur oleh **Document-Level Permissions**.*

```mermaid
erDiagram
    USERS ||--|{ ITEMS : "owns"
    USERS ||--|{ CATEGORIES : "owns"
    USERS ||--|{ TRANSACTIONS : "owns"
    USERS ||--|{ ACTIVITY_LOGS : "performs"
    
    USERS {
        string id PK "Appwrite User ID"
        string name
        string email
    }

    ITEMS {
        string id PK "Appwrite Document ID"
        string userId FK "Owner"
        string categoryId "Optional FK"
        string name
        string brand "Optional"
        string description
        int quantity
        int min_quantity
        string unit
        float purchasePrice
        float salePrice
        string imageId "Appwrite File ID"
    }

    CATEGORIES {
        string id PK "Appwrite Document ID"
        string userId FK "Owner"
        string name
    }

    TRANSACTIONS {
        string id PK "Appwrite Document ID"
        string userId FK "Owner"
        string itemId FK
        string type "IN/OUT"
        datetime date
        int quantity
        string note
    }

    ACTIVITY_LOGS {
        string id PK "Appwrite Document ID"
        string userId FK "Actor"
        datetime timestamp
        string description
        string activity_type
    }
```