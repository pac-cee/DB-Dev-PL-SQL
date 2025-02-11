-- Project Structure
/*
wallet-app/
├── backend/
│   ├── database/
│   │   ├── tables/
│   │   ├── procedures/
│   │   ├── functions/
│   │   ├── triggers/
│   │   └── packages/
│   └── api/
│       └── controllers/
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── utils/
│   └── public/
└── docs/
*/

-- 1. Database Tables Creation
CREATE TABLE users (
    user_id NUMBER GENERATED ALWAYS AS IDENTITY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    email VARCHAR2(100) NOT NULL UNIQUE,
    password_hash VARCHAR2(256) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_users PRIMARY KEY (user_id)
);

CREATE TABLE wallets (
    wallet_id NUMBER GENERATED ALWAYS AS IDENTITY,
    user_id NUMBER NOT NULL,
    wallet_name VARCHAR2(50) NOT NULL,
    currency VARCHAR2(3) DEFAULT 'USD',
    balance NUMBER(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_wallets PRIMARY KEY (wallet_id),
    CONSTRAINT fk_wallets_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE categories (
    category_id NUMBER GENERATED ALWAYS AS IDENTITY,
    user_id NUMBER NOT NULL,
    category_name VARCHAR2(50) NOT NULL,
    category_type VARCHAR2(10) CHECK (category_type IN ('INCOME', 'EXPENSE')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_categories PRIMARY KEY (category_id),
    CONSTRAINT fk_categories_users FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE transactions (
    transaction_id NUMBER GENERATED ALWAYS AS IDENTITY,
    wallet_id NUMBER NOT NULL,
    category_id NUMBER NOT NULL,
    amount NUMBER(15,2) NOT NULL,
    transaction_type VARCHAR2(10) CHECK (transaction_type IN ('INCOME', 'EXPENSE')),
    description VARCHAR2(200),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_transactions PRIMARY KEY (transaction_id),
    CONSTRAINT fk_transactions_wallets FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id),
    CONSTRAINT fk_transactions_categories FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE budgets (
    budget_id NUMBER GENERATED ALWAYS AS IDENTITY,
    user_id NUMBER NOT NULL,
    category_id NUMBER NOT NULL,
    amount NUMBER(15,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_budgets PRIMARY KEY (budget_id),
    CONSTRAINT fk_budgets_users FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_budgets_categories FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 2. Package for User Management
CREATE OR REPLACE PACKAGE user_mgmt AS
    -- Create new user
    PROCEDURE create_user(
        p_username IN VARCHAR2,
        p_email IN VARCHAR2,
        p_password IN VARCHAR2,
        p_user_id OUT NUMBER
    );
    
    -- Authenticate user
    FUNCTION authenticate_user(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN NUMBER;
    
    -- Update user details
    PROCEDURE update_user(
        p_user_id IN NUMBER,
        p_email IN VARCHAR2
    );
END user_mgmt;
/

-- 3. Package for Wallet Management
CREATE OR REPLACE PACKAGE wallet_mgmt AS
    -- Create new wallet
    PROCEDURE create_wallet(
        p_user_id IN NUMBER,
        p_wallet_name IN VARCHAR2,
        p_currency IN VARCHAR2,
        p_wallet_id OUT NUMBER
    );
    
    -- Get wallet balance
    FUNCTION get_wallet_balance(
        p_wallet_id IN NUMBER
    ) RETURN NUMBER;
    
    -- Add transaction
    PROCEDURE add_transaction(
        p_wallet_id IN NUMBER,
        p_category_id IN NUMBER,
        p_amount IN NUMBER,
        p_transaction_type IN VARCHAR2,
        p_description IN VARCHAR2
    );
END wallet_mgmt;
/

-- 4. Package for Budget Management
CREATE OR REPLACE PACKAGE budget_mgmt AS
    -- Create budget
    PROCEDURE create_budget(
        p_user_id IN NUMBER,
        p_category_id IN NUMBER,
        p_amount IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE
    );
    
    -- Check budget status
    FUNCTION get_budget_status(
        p_budget_id IN NUMBER
    ) RETURN NUMBER;
    
    -- Get category spending
    FUNCTION get_category_spending(
        p_category_id IN NUMBER,
        p_start_date IN DATE,
        p_end_date IN DATE
    ) RETURN NUMBER;
END budget_mgmt;
/

-- 5. Triggers for Automatic Updates
CREATE OR REPLACE TRIGGER trg_update_wallet_balance
AFTER INSERT OR UPDATE ON transactions
FOR EACH ROW
DECLARE
    v_wallet_balance NUMBER;
BEGIN
    IF :NEW.transaction_type = 'INCOME' THEN
        UPDATE wallets 
        SET balance = balance + :NEW.amount
        WHERE wallet_id = :NEW.wallet_id;
    ELSE
        UPDATE wallets 
        SET balance = balance - :NEW.amount
        WHERE wallet_id = :NEW.wallet_id;
    END IF;
END;
/

-- 6. Views for Reporting
CREATE OR REPLACE VIEW vw_monthly_spending AS
SELECT 
    u.username,
    c.category_name,
    EXTRACT(MONTH FROM t.transaction_date) as month,
    EXTRACT(YEAR FROM t.transaction_date) as year,
    SUM(t.amount) as total_amount
FROM transactions t
JOIN wallets w ON t.wallet_id = w.wallet_id
JOIN users u ON w.user_id = u.user_id
JOIN categories c ON t.category_id = c.category_id
WHERE t.transaction_type = 'EXPENSE'
GROUP BY u.username, c.category_name, 
         EXTRACT(MONTH FROM t.transaction_date),
         EXTRACT(YEAR FROM t.transaction_date);

-- 7. Report Generation Function
CREATE OR REPLACE FUNCTION generate_expense_report(
    p_user_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE
) RETURN SYS_REFCURSOR IS
    v_result SYS_REFCURSOR;
BEGIN
    OPEN v_result FOR
        SELECT 
            c.category_name,
            SUM(t.amount) as total_amount,
            COUNT(*) as transaction_count,
            MIN(t.amount) as min_amount,
            MAX(t.amount) as max_amount,
            AVG(t.amount) as avg_amount
        FROM transactions t
        JOIN wallets w ON t.wallet_id = w.wallet_id
        JOIN categories c ON t.category_id = c.category_id
        WHERE w.user_id = p_user_id
        AND t.transaction_date BETWEEN p_start_date AND p_end_date
        GROUP BY c.category_name;
    
    RETURN v_result;
END;

/