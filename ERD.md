#### 3.4.3 Diagram ERD (Konseptual untuk Appwrite)
*Catatan: Ini adalah representasi konseptual. Di Appwrite, relasi diimplementasikan melalui ID dokumen yang disimpan, dan keamanan diatur oleh Aturan Akses (Permissions).*

```mermaid
erDiagram
    USERS ||--|{ STORES : "manages"
    STORES ||--o{ ITEMS : "contains"
    STORES ||--o{ CATEGORIES : "contains"
    STORES ||--o{ TRANSACTIONS : "contains"
    STORES ||--o{ ACTIVITY_LOGS : "records"
    
    USERS {
        string id PK "Appwrite User ID"
        string name
        string email
    }

    STORES {
        string id PK "Appwrite Document ID"
        string user_id FK "Owner"
        string name
        string description
    }

    ITEMS {
        string id PK "Appwrite Document ID"
        string store_id FK
        string category_id FK
        string name
        string description
        int qty
        int min_qty
        string image_id "Appwrite File ID"
    }

    CATEGORIES {
        string id PK "Appwrite Document ID"
        string store_id FK
        string name
    }

    TRANSACTIONS {
        string id PK "Appwrite Document ID"
        string store_id FK
        string item_id FK
        string type "IN/OUT"
        datetime date
        int qty
        string note
    }

    ACTIVITY_LOGS {
        string id PK "Appwrite Document ID"
        string store_id FK
        string user_id FK "Actor"
        datetime timestamp
        string description
        string activity_type
    }
```