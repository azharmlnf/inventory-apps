#### 3.4.3 Diagram ERD (sederhana)
```mermaid
erDiagram
    ITEMS ||--o{ TRANSACTION_LINES : contains
    CATEGORIES ||--o{ ITEMS : groups
    TRANSACTIONS ||--o{ TRANSACTION_LINES : includes
    ITEMS ||--o{ STOCK_MOVEMENTS : changes

    ITEMS {
        int id PK
        string code
        string name
        string description
        int category_id FK
        string unit
        double buy_price
        double sell_price
        int qty
        int min_qty
        string image_path
        datetime created_at
        datetime updated_at
    }

    CATEGORIES {
        int id PK
        string name
        int parent_id
    }

    TRANSACTIONS {
        int id PK
        string type
        datetime date
        string partner
        string note
        double total_amount
        datetime created_at
    }

    TRANSACTION_LINES {
        int id PK
        int transaction_id FK
        int item_id FK
        int qty
        double unit_price
        double subtotal
    }

    STOCK_MOVEMENTS {
        int id PK
        int item_id FK
        int change
        string source
        datetime date
        string note
    }