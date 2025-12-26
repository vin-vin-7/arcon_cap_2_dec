create database airconi_trading_db




	-- 3. Roles table
CREATE TABLE roles (
    ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_Name VARCHAR(20) NOT NULL,
    role_Description TEXT
);

	--  Admin Users table
CREATE TABLE admin_users (
    ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_Name VARCHAR(25) UNIQUE NOT NULL,
    first_Name VARCHAR(50) NOT NULL,
    last_Name VARCHAR(50) NOT NULL,
    contact_No VARCHAR(20) NOT NULL, 
	birthday DATE NOT NULL,
    email_Address VARCHAR(255) UNIQUE NOT NULL,
    home_Address VARCHAR(255) NOT NULL,    
    password_Hash VARCHAR(255) NOT NULL,
    created_At TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    updated_At TIMESTAMPTZ,
    updated_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    status varchar(50) DEFAULT 'ACTIVE',
    is_Online BOOLEAN DEFAULT FALSE, 
    login_Attempts INT DEFAULT 0,
    last_failed_login TIMESTAMPTZ,
    last_Login TIMESTAMPTZ
	admin_user_avatar_media_id INT REFERENCES media_url(id) ON DELETE SET NULL;
);

ALTER TABLE admin_users
  ALTER COLUMN status SET DEFAULT 'ACTIVE';

	-- User roles junction table (for many-to-many)
CREATE TABLE user_roles (
    user_id INT REFERENCES admin_users(ID) ON DELETE CASCADE,
    role_id INT REFERENCES roles(ID) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

	-- Work schedule table
CREATE TABLE work_schedule (
    ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_ID INT NOT NULL REFERENCES admin_users(ID) ON DELETE CASCADE, 
    day_of_Week VARCHAR(10) NOT NULL,
    login_Time TIME,
    logout_Time TIME,
    is_Restday BOOLEAN DEFAULT FALSE,
    created_At TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    updated_At TIMESTAMPTZ,
    updated_By INT REFERENCES admin_users(ID) ON DELETE SET NULL
);



-- product table: products should be added through stages to prevent foreign key constraints. 
CREATE TABLE select * from products(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	manufacturer_ID INT REFERENCES manufacturer(ID) NOT NULL,
	product_Model VARCHAR(100) UNIQUE NOT NULL,
	product_Series VARCHAR(100),
	sku VARCHAR(100) NOT NULL UNIQUE,
	part_Number_A VARCHAR(100) NOT NULL UNIQUE,
	part_Number_B VARCHAR(100),
	form_factor_ID INT REFERENCES form_factors(ID), -- (Drop Down)
	status  varchar(50) DEFAULT 'ACTIVE', -- options (Drop Down):  DISCONTINUED, ARCHIVED
	original_selling_Price NUMERIC(12,2) NOT NULL,
	discounted_selling_price NUMERIC(12,2),
	discount_Type Varchar(50), -- options (Drop Down):  NONE, PERCENTAGE, AMOUNT
	discount_Value NUMERIC(10,2	),
	isDiscounted BOOLEAN DEFAULT FALSE,
	has_installation_service BOOLEAN DEFAULT FALSE;
	actual_selling_price NUMERIC(12,2),
	ar_Url VARCHAR(255),
	created_At TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    updated_At TIMESTAMPTZ,
    updated_By INT REFERENCES admin_users(ID) ON DELETE SET NULL
	manufacturer_warranty_years int,
	outright_replacement_days int,
	gross_weight_a numeric(6,2),
	gross_weight_b numeric(6,2),
	total_gross_weight numeric(6,2),
	
);



-- (drop down) 
CREATE TABLE manufacturer(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	manufacturer_Name VARCHAR(100) NOT NULL UNIQUE,
	brand_Name VARCHAR(100) NOT NULL UNIQUE,
	manufacturer_Logo VARCHAR(255),
	official_Website VARCHAR(255),
	added_At TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	added_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
	updated_At TIMESTAMPTZ,
    updated_By INT REFERENCES admin_users(ID) ON DELETE SET NULL
);
-- (Drop Down)
CREATE TABLE  form_factors(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	form_Factor VARCHAR(50) NOT NULL UNIQUE,
	form_Factor_Description TEXT,
	created_At TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    updated_At TIMESTAMPTZ,
    updated_By INT REFERENCES admin_users(ID) ON DELETE SET NULL
)

CREATE TABLE technology_types( -- information like, inverter, humidifier etc...
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    technology_Name VARCHAR(50) NOT NULL UNIQUE,
	technology_Desc TEXT,
	created_At TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_By INT REFERENCES admin_users(ID),
	updated_At TIMESTAMPTZ,
    updated_By INT REFERENCES admin_users(ID)
)

insert into form_factors(form_Factor, form_Factor_Description) Values 
('Wall-mounted Non-Inverter', 'Mounted high on a wall, usually split type.'), 
('Ceiling Suspended', 'Installed in ceiling; commonly distributes air in 4 directions.'),
('Ceiling Cassette-Type', 'Installed in ceiling; commonly distributes air in 4 directions.'),
('Floor-standing / Tower','Tall vertical units; often commercial spaces.'),
('Window type', 'All-in-one, fits inside a window.'),
('Portable / Tower', 'Small, on wheels, easy to move.')

INSERT INTO technology_types (technology_Name, technology_Desc)
VALUES
('Inverter', 'Compressor adjusts speed to maintain temperature efficiently; energy-saving.'),
('Dual Inverter', 'Advanced inverter with two rotary compressors; more stable, quiet, and efficient.'),
('Non-Inverter / Fixed-Speed', 'Compressor runs at full speed or off; less efficient but cheaper'),
('Rotary Compressor', 'Simple compressor type for smaller AC units.'),
('Scroll Compressor', 'Common in large units; durable and efficient.'),
('Smart / WiFi Control', 'Connects to apps for remote control.'),
('Eco / Energy-saving Mode','Saves electricity; can be a mode in inverter units.'),
('Air Purification','Filters, ionizers, or plasma technology to clean air.'),
('Dehumidifier', 'Removes humidity from the room.'),
('Quiet / Low Noise', 'Reduces operating noise.');

	-- product_technologies junction table (for many-to-many)
CREATE TABLE product_technologies (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    technology_id INT NOT NULL REFERENCES technology_types(id) ON DELETE CASCADE,
    UNIQUE (product_id, technology_id)
);

CREATE TABLE  specification_keys (
    ID  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    KeyName VARCHAR(50) UNIQUE NOT NULL  -- e.g., "Horsepower", "Warranty", "Dimensions"
);

CREATE TABLE  select * from technical_specifications ( -- records the values of product spec: eg length = 34cm, Horsepower = 1.5
    ID SERIAL PRIMARY KEY,
    Product_ID INT NOT NULL REFERENCES products(ID) ON DELETE CASCADE,
    Key_ID INT NOT NULL REFERENCES specification_keys(ID) ON DELETE CASCADE,
    Value VARCHAR(255) NOT NULL
);

-- stores the number of wish count if product is currently of of stock
CREATE TABLE wishlists (
    wishlist_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(customer_id, product_id)
);

insert in

insert into specification_keys (keyName) values ('Cooling capacity'),('Length(cm)'),('Width(cm)'),('Height(cm'),('Gross Weight(Kg)'), ('Net Weight')
insert into technical_specifications (Product_ID, Key_ID, Value) VALUES (1,1,'1 HP'), (1,2,'Indoor: 21.1 | Outdoor: 24.2'), (1,3,'Indoor: 82 | Outdoor: 66'),
(1,4,'Indoor: 29.9 | Outdoor: 47.5'), (1,5,'Indoor: 10.6 | Outdoor: 20.8'), (1,6,'Indoor: 9.2 | Outdoor: 19.1')

INSERT INTO product_technologies (product_ID, technology_ID) values (1,1), (1,7)


select * from technical_specifications

INSERT INTO products(
    manufacturer_ID,
    product_Model,
    product_Series,
    sku,
    part_Number_A,
    part_Number_B,
    form_factor_ID,
    status,
    original_selling_price,
    discounted_selling_price,
    discount_type,
    discount_value,
    isDiscounted,
    actual_selling_price,
    ar_url,
    created_by,
    updated_at,
    updated_by
) VALUES (
    1,
    'AR09TYHYHJJ',
    'Basic Windfree Series',
    'SKU-00002',
    'AR09TYHYHJJ',
    'AR24TYGCGWKXTC',
    6,
    'ACTIVE',
    29995.00,
    NULL,              -- no discounted price
    'NONE',
    0.00,
    FALSE,
    29995.00,          -- same as original
    'https://example.com/ar/ac-1000',
    1,
    CURRENT_TIMESTAMP,
    1
);



select * from customers




-- customer table
CREATE TABLE customers(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	-- personal_information
	first_Name VARCHAR(150) NOT NULL,
	last_Name VARCHAR(150) NOT NULL,
	middle_Name VARCHAR(150),
	birthday DATE NOT NULL,

	-- Account info
	email VARCHAR(255) UNIQUE NOT NULL,
	contact_No VARCHAR(20) UNIQUE NOT NULL,
	customer_avatar_media_id INT REFERENCES media_url(id) ON DELETE SET NULL,
	
	-- Audit
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
	is_Online BOOLEAN DEFAULT FALSE,
	last_failed_login TIMESTAMPTZ,
    last_Login TIMESTAMPTZ
);



-- this will hold media URLS from file hosting site
CREATE TABLE media_url (
    ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    url VARCHAR(500) NOT NULL,
    type VARCHAR(50),                      -- e.g., 'image', 'thumbnail'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	created_by INT REFERENCES admin_users(id) ON DELETE SET NULL
);


CREATE TABLE customer_Addresses (
    ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(ID) ON DELETE CASCADE,	
    house_unit VARCHAR(100), --House/Unit Number, Building/Subdivision
    street_Name VARCHAR(100),
    barangay VARCHAR(100),
    city VARCHAR(100),
    province VARCHAR(100),
    zip_code VARCHAR(10),
    landmark VARCHAR(255),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
	updated_at TIMESTAMPTZ
);

select * from customer_addresses 
-- supplier table
CREATE TABLE suppliers(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	-- COMPANY BASIC INFO
	supplier_Name VARCHAR(255) NOT NULL UNIQUE,
	proprietor_Name VARCHAR(150),
	proprieto_contact_no VARCHAR(20),
	dti_Business_Number VARCHAR(50) UNIQUE,
	tin_Number VARCHAR(20) UNIQUE,
	offical_website VARCHAR(255),
	landline_No VARCHAR(20),
	-- contact details of company representative
	supplier_rep VARCHAR(150),
	rep_email VARCHAR(255),
	rep_contact_no VARCHAR(20),
	-- Business Address
	house_unit VARCHAR(100), --House/Unit Number, Building/Subdivision
    street_Name VARCHAR(100),
    barangay VARCHAR(100),
    city VARCHAR(100),
    province VARCHAR(100),
    zip_code VARCHAR(10),
    landmark VARCHAR(255),
	-- Business logo
	supplier_logo_media_id INT REFERENCES media_url(id) ON DELETE SET NULL,
	-- additional info
	notes TEXT,
	-- Audit
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	created_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ
);


-- purchase order to be sent to the supplier
CREATE TABLE purchase_order(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_id INT NOT NULL REFERENCES suppliers(id),
    po_number VARCHAR(50) UNIQUE NOT NULL,
    payment_type VARCHAR(50), -- Cash, Credit, Installment, etc.
	arcon_branch_address INT REFERENCES arcon_store_branches(ID),
    expected_delivery DATE,
	freight_cost NUMERIC(12,2) DEFAULT 0,
	total_amount NUMERIC(14,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
	created_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ
);


-- contents of the po, multiple items
CREATE TABLE purchase_order_articles (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    purchase_order_id INT NOT NULL REFERENCES purchase_order(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id),
    qty_ordered INT NOT NULL,
    unit_price NUMERIC(12,2), -- <--- if supplier gives price later, allow NULL
    total_cost NUMERIC(12,2), -- unit_price * qty_ordered (optional)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Records each time the supplier delivers items (could be partial).
CREATE TABLE purchased_order_received (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    purchase_order_id INT NOT NULL REFERENCES purchase_order(id) ON DELETE CASCADE,
    received_date TIMESTAMPTZ DEFAULT NOW(),
    total_received_amount NUMERIC(14,2), -- <--- will be auto-calculated
	received_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Actual delivered items per receiving event. 
CREATE TABLE received_articles (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    purchased_order_received_id INT NOT NULL REFERENCES purchased_order_received(ID) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id),
    qty_received INT NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    total_cost NUMERIC(12,2), -- unit_price * qty_received
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- The Actual Inventory Table
CREATE TABLE inventory (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id),
    serial_number VARCHAR(150),

	-- Source
    purchased_order_received_id INT REFERENCES purchased_order_received(id),
	supplier_return_item_id INT REFERENCES supplier_return_items(id) ON DELETE SET NULL,

	-- Classification
	received_as VARCHAR(50) NOT NULL
        CHECK (received_as IN ('PURCHASE_ORDER', 'REPLACEMENT', 'ADJUSTMENT')),

	status VARCHAR(50) NOT NULL
        CHECK (status IN ('GOOD_STOCK', 'DEFECTIVE', 'RETURN_PENDING', 'RETURNED_TO_SUPPLIER','REPLACED','RESERVED', 'SOLD'))
        DEFAULT 'GOOD_STOCK',
		
	remarks TEXT,
	created_at TIMESTAMPTZ DEFAULT NOW(),
	added_By INT REFERENCES admin_users(ID) ON DELETE SET NULL,
	updated_At TIMESTAMPTZ,
    updated_By INT REFERENCES admin_users(ID) ON DELETE SET NULL
);



-- if arcon has multiple branch. this table is useful in po and return transaction
CREATE TABLE arcon_store_branches (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_code VARCHAR(50) UNIQUE NOT NULL,
    branch_name VARCHAR(150),
    contact_number VARCHAR(20),
    email VARCHAR(255),
	contact_admin INT REFERENCES admin_users(ID) ON DELETE SET NULL,
    is_main_branch BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO customer_Addresses (
    customer_id,
    house_unit,
    street_name,
    barangay,
    city,
    province,
    zip_code,
    landmark,
    is_default
) VALUES (
    1,                      								-- customer_id
    'Lot 12 Block 17 San Lorenzo Subdivision',              -- house_unit
    'San Lorenzo Subdivision',        						-- street_name
    'Barangay San Isidro',  								-- barangay
    'Quezon City',          								-- city
    'Metro Manila',         								-- province
    '1109',                 								-- zip_code
    'Near Robinsons Mall',  								-- landmark
    TRUE                   								 	-- is_default
);

-- tags for search function eg. Xcool, white, panasonic, R32, modern etc....
CREATE TABLE tags(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	tag_name VARCHAR(50) UNIQUE NOT NULL,
	created_at TIMESTAMPTZ DEFAULT NOW()
);

-- junction table of products and tags
CREATE TABLE product_tags(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	product_id INT NOT NULL REFERENCES products(ID) ON DELETE CASCADE,
	tag_id INT NOT NULL REFERENCES tags(ID) ON DELETE CASCADE
);

-- if a product/s is defective, a return_order must be made to send the product to the supplier 
-- CREATED → SENT → PICKED_UP / SHIPPED → COMPLETED
CREATE TABLE supplier_returns (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_id INT NOT NULL REFERENCES suppliers(id),

    return_number VARCHAR(50) UNIQUE NOT NULL,
    related_po_id INT REFERENCES purchase_order(id),

    return_date DATE DEFAULT CURRENT_DATE,
	return_method VARCHAR(30) NOT NULL
    CHECK (return_method IN ('SUPPLIER_PICKUP', 'SHIP_TO_SUPPLIER')),
	
	-- if to be ship to seller
	courier_name VARCHAR(100),
	tracking_number VARCHAR(100),	
	pickup_date DATE,
	shipped_date DATE,
	shipping_cost NUMERIC(12,2),
	
	
    status VARCHAR(30) DEFAULT 'CREATED'
        CHECK (status IN (
            'CREATED',
            'SENT_VIA_SUPPLIER''S EMAIL',
            'APPROVED', -- via communication (email, online chat, sms.. )
            'REJECTED', -- via communication (email, online chat, sms.. )
            'COMPLETED' -- the replacement is acquired
        )),

    total_items INT DEFAULT 0,
    total_amount NUMERIC(14,2),

    remarks TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by INT REFERENCES admin_users(id) ON DELETE SET NULL
);

-- supplier_return_items (line items)
CREATE TABLE supplier_return_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    supplier_return_id INT NOT NULL
        REFERENCES supplier_returns(id) ON DELETE CASCADE,

    product_id INT NOT NULL REFERENCES products(id),

    inventory_id INT REFERENCES inventory(id),
    serial_number VARCHAR(150),

    unit_cost NUMERIC(12,2),
    total_cost NUMERIC(12,2),

    return_reason VARCHAR(255), -- or FK to return_reasons
    condition_notes TEXT
);

-- junction table for media and supplier_return_items (line items), so that we can show the defect via media
CREATE TABLE supplier_return_item_media (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_return_item_id INT NOT NULL
        REFERENCES supplier_return_items(id) ON DELETE CASCADE,

    media_id INT NOT NULL
        REFERENCES media_url(id) ON DELETE CASCADE
);


INSERT INTO product_tags (product_id, tag_id)
VALUES 
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5);
 


SELECT * FROM admin_users
SELECT * FROM products 
SELECT * FROM technical_specifications WHERE product_ID = 1
SELECT * FROM specification_keys
SELECT * FROM product_technologies
SELECT * FROM technology_types
SELECT * FROM form_Factors
SELECT * FROM customers
SELECT * FROM customer_Addresses
SELECT * FROM suppliers
SELECT * FROM inventory
SELECT * FROM product_TAGS




SELECT 
    p.id AS product_ID,
    p.product_model,
    p.product_series,
    p.sku,
    p.original_selling_price,
    p.discounted_selling_price,
    p.actual_selling_price,
    m.manufacturer_name,
	m.brand_Name
FROM products p
JOIN manufacturer m
    ON p.manufacturer_ID = m.ID;

SELECT DISTINCT p.*
FROM products p
LEFT JOIN product_tags pt ON pt.product_id = p.id
LEFT JOIN tags t ON t.id = pt.tag_id
WHERE 
    p.product_model ILIKE '%samsung%'
    OR t.tag_name ILIKE '%ecomode%';


SELECT 
    p.id AS product_id,
    p.product_model,
    sk.keyname AS specification_key,
    ts.value AS specification_value
FROM products p
JOIN technical_specifications ts
    ON p.id = ts.product_id
JOIN specification_keys sk
    ON ts.key_id = sk.id;


-- Chat and Notification
-- CHAT (conversation + messages)
-- NOTIFICATIONS (alerts for users)
-- MEDIA (attachments shared in chat)

CREATE TABLE chat_conversations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id INT NOT NULL
        REFERENCES customers(id) ON DELETE CASCADE,

    assigned_csm_id INT
        REFERENCES admin_users(id) ON DELETE SET NULL,

    subject VARCHAR(150), -- "Order Issue", "Warranty Claim"

    status VARCHAR(30) DEFAULT 'OPEN'
        CHECK (status IN ('OPEN', 'PENDING', 'CLOSED')),

    is_archived BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ
);
-- chat message (actual message)
CREATE TABLE chat_messages (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    conversation_id INT NOT NULL
        REFERENCES chat_conversations(id) ON DELETE CASCADE,

    sender_type VARCHAR(20) NOT NULL
        CHECK (sender_type IN ('ADMIN', 'CUSTOMER')),

    sender_id INT NOT NULL,

    message TEXT,
    message_type VARCHAR(20) DEFAULT 'TEXT'
        CHECK (message_type IN ('TEXT', 'IMAGE', 'VIDEO', 'FILE')),

    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT NOW()
);
-- chat_message_media (Attachments)
CREATE TABLE chat_message_media (
    ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    chat_message_id INT NOT NULL
        REFERENCES chat_messages(id) ON DELETE CASCADE,

    file_url TEXT NOT NULL,
    file_name VARCHAR(255),
    file_type VARCHAR(50), -- image/jpeg, application/pdf
    file_size NUMERIC(5,2),

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- THE NOTIFICATION TABLE (All notifications will be here)
CREATE TABLE notifications (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_type VARCHAR(20) NOT NULL
        CHECK (user_type IN ('ADMIN', 'CUSTOMER')),

    user_id INT NOT NULL,

    title VARCHAR(150),
    text_message TEXT,

    notification_type VARCHAR(50), -- CHAT, ORDER, RETURN, SERVICE
    reference_id INT, -- chat_conversation_id, order_id

    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- READ / UNREAD HANDLING (Chat-specific)
CREATE TABLE chat_conversation_reads (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    conversation_id INT NOT NULL
        REFERENCES chat_conversations(id) ON DELETE CASCADE,

    user_type VARCHAR(20)
        CHECK (user_type IN ('ADMIN', 'CUSTOMER')),

    user_id INT NOT NULL,

    last_read_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE (conversation_id, user_type, user_id)
);

------------------------------------------------------------------------ Customer Checkout Process ----------------------------------------------------------------------------

/* 6. FULL PROCESS FLOW (Final)
1️⃣ 	Add to Cart
	cart → cart_items
		↓
2️⃣ 	Checkout Selected Items
	checkouts → checkout_items (snapshot)
		↓
3️⃣ 	Payment
	payment_transactions
		• If PayMongo → store IDs, status
		• If COD → mark cod_status
		↓
4️⃣ 	Final Summary
	customer_transactions
		↓
5️⃣ 	Convert to Order
	orders → order_items (final snapshot)
*/


/*installation options to be GLOBAL, and in Products (CRUD) admins will just assign which options apply via checkboxes.
✅ installation_service_options - which will be use as add-on to the purchase eg. "I have my own installer (+ 0.00)", "3-meters of piping (FREE)", 
"3-meters of piping (FREE) + add 3-meters of piping(+P 2,500.00)" etc... 
Global list of options (no product_id) */
CREATE TABLE installation_std_service_options(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	option_code VARCHAR(10) UNIQUE, -- Option A, Option B, Option C 
	description TEXT,
	included_pipe_in_meters Numeric(4,2),
	price NUMERIC(12,2),
	is_default BOOLEAN DEFAULT FALSE,
	is_active BOOLEAN DEFAULT TRUE,
	 created_at TIMESTAMPTZ DEFAULT NOW()
);

/*additonal installation options to be GLOBAL, and in Products (CRUD) admins will just assign which options apply via checkboxes.
✅ installation_additional_service_options - which will be use as add-on to the purchase eg. "None", "Dismantling of old unit",  etc... 
Global list of options (no product_id) */
CREATE TABLE  installation_additional_service_options(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	option_code VARCHAR(10) UNIQUE, -- Option A, Option B, Option C 
	description TEXT,
	price NUMERIC(12,2),
	is_default BOOLEAN DEFAULT FALSE,
	is_active BOOLEAN DEFAULT TRUE,
	created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1. CART SYSTEM (one to one)
CREATE TABLE carts (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
 

/*	cart_items
	! cart_items (NO snapshot price here)
	! No price stored
	! No meters stored
	! These are computed live when viewing cart
	! cart_items (NO snapshot price here)	
*/
CREATE TABLE cart_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cart_id INT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id),
    quantity INT NOT NULL DEFAULT 1,
	  
    -- installation services
    std_installation_service_option_id INT REFERENCES installation_std_service_options(id),
    additional_installation_service_option_id INT REFERENCES installation_additional_service_options(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

/* CHECKOUT (Snapshot Begins Here)
Once the customer clicks Checkout Selected Items, prices and installation totals must be locked. */
CREATE TABLE checkouts (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id),
    delivery_address_id INT REFERENCES customer_addresses(id),
	arcon_store_branches_id INT REFERENCES arcon_store_branches(id),

    delivery_cost NUMERIC(12,2),
    payment_method VARCHAR(20), -- 'COD' or 'PAYMONGO'
    shipping_method VARCHAR(50), -- Lalamove, In-house, Pickup

    created_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'PENDING'
);

/* checkout_items (Snapshotted prices & service costs) 
✔ TOTAL = Sum of checkout_items.total_item_amount + delivery_cost
✔ Safe even if product price changes later
*/
CREATE TABLE checkout_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    checkout_id INT NOT NULL REFERENCES checkouts(id) ON DELETE CASCADE,
	product_id INT NOT NULL REFERENCES products(id),
    qty INT NOT NULL,

    -- PRICE SNAPSHOTS
    product_price NUMERIC(12,2),     -- actual_selling_price at checkout moment
    std_service_price NUMERIC(12,2),
    additional_service_price NUMERIC(12,2),

    total_item_amount NUMERIC(12,2), -- (product + services) * qty

    -- SNAPSHOTTED INSTALL SERVICE IDs
    std_installation_option_id INT REFERENCES installation_std_service_options(id),
    additional_installation_option_id INT REFERENCES installation_additional_service_options(id)
);


/*3. PAYMENT SYSTEM (PayMongo + COD)
payment_transactions
This stores COD or PayMongo results.
✔ If COD → no PayMongo IDs
✔ If PayMongo → store IDs, status, timestamps
✔ One checkout = one transaction
*/
CREATE TABLE payment_transactions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    checkout_id INT NOT NULL REFERENCES checkouts(id) ON DELETE CASCADE,

    payment_method VARCHAR(20) NOT NULL,  -- COD or PAYMONGO

    -- FOR PAYMONGO ONLY
    paymongo_source_id VARCHAR(255),
    paymongo_payment_id VARCHAR(255),
    paymongo_status VARCHAR(50), -- paid, pending, failed
    paid_at TIMESTAMPTZ,

    -- FOR COD ONLY
    cod_status VARCHAR(20), -- PENDING, TO_COLLECT, COLLECTED

    amount NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

/* 	CUSTOMER TRANSACTION (Grand Summary) This is the final high-level completed transaction 
--	I might add discount
*/
CREATE TABLE customer_transactions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    checkout_id INT NOT NULL REFERENCES checkouts(id),
    payment_transaction_id INT REFERENCES payment_transactions(id),
	customer_id INT NOT NULL REFERENCES customers(id),

    delivery_cost NUMERIC(12,2),
    total_item_cost NUMERIC(12,2),
    grand_total NUMERIC(12,2),

    payment_method VARCHAR(20),
    shipping_method VARCHAR(50),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(30) DEFAULT 'PROCESSING' 
);



-- i need the delivery computation to proceed (UPDATED: Products (added gross weight) and coordinates for (arcon address and customer address)
-- will use lalamove quotation API

/* ORDERS (Snapshot of Checkout Items → Becomes Order Items) */
CREATE TABLE orders (
    ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_transaction_id INT NOT NULL REFERENCES customer_transactions(id) ON DELETE CASCADE,
	order_ref_code VARCHAR(255) UNIQUE NOT NULL
    created_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(30) DEFAULT 'TO PACK' -- TO PACK, TO SHIP, IN TRANSIT, CANCELLED, COMPLETED
);

/* order_items (copied from checkout_items; final snapshot) */
CREATE TABLE order_items (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,

    product_id INT NOT NULL REFERENCES products(id),
    qty INT NOT NULL,

    product_price NUMERIC(12,2),
    std_service_price NUMERIC(12,2),
    additional_service_price NUMERIC(12,2),

    total_item_amount NUMERIC(12,2),

    std_installation_option_id INT,
    additional_installation_option_id INT
);


-----------------------------------------------------------------------------end customer checkout process-----------------------------------------------
		alter table products add column form_factor_id REFERENCES form_factors(ID)
		select * from products
		select * from form_factors

-----------------------------------------------------------------------------services booking ------------------------------------------------------

-- This identifies the type of aircon.
CREATE TABLE select * from service_aircon_type(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(100) UNIQUE NOT NULL
);

-- Groups of services
CREATE TABLE select * from service_categories (
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- cleaning, freon charging, repair etc...
	service_name VARCHAR(255) NOT NULL,
	description TEXT
);

-- Each aircon type + service category combination.
CREATE TABLE services(
	ID int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	service_aircon_type_id INT NOT NULL REFERENCES service_aircon_type(ID) ON DELETE CASCADE,
	service_categories_id INT NOT NULL REFERENCES service_categories(ID) ON DELETE CASCADE,
	UNIQUE (service_aircon_type_id, service_categories_id) 
);

-- A service can have multiple price tiers by HP range.
CREATE TABLE service_price_tiers(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	services_id INT NOT NULL REFERENCES services(ID) ON DELETE CASCADE,
	capacity_range VARCHAR(50) NOT NULL,
	price NUMERIC(12,2) NOT NULL,
	sort_order INT DEFAULT 1 
);

-- 	booking must expire (time) and must push through
-- 	BOOKINGS TABLE (like “orders”)
CREATE TABLE service_bookings(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	booking_ref_code VARCHAR(255) UNIQUE, 									-- BOOKING reference code
	customer_id INT NOT NULL REFERENCES customers(ID),
	status VARCHAR(50) DEFAULT 'Pending',
	customer_addresses_id INT NOT NULL REFERENCES customer_addresses(ID),
	schedule_date TIMESTAMP NOT NULL,
	customer_note TEXT,
	
	-- payment
	payment_method VARCHAR(50) NOT NULL DEFAULT 'AFTER SERVICE', 	-- paymongo | after_service
	payment_status VARCHAR(50) NOT NULL DEFAULT 'PENDING',			-- pending | paid | failed | cancelled
	payment_reference VARCHAR(255),									-- paymongo payment id
	paid_At TIMESTAMP,
	approx_completion_date TIMESTAMP,
	total_amount NUMERIC(12,2),										-- sum of booking items
	created_at TIMESTAMP DEFAULT NOW()
);
-- 	Booking Items Table
CREATE TABLE service_booking_items(
	ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	service_bookings_id INT NOT NULL REFERENCES service_bookings(ID) ON DELETE CASCADE,
	services_id INT NOT NULL REFERENCES services(ID),
	quantity INT NOT NULL DEFAULT 1,

	-- price snapshot
	capacity_range VARCHAR(50),
	price NUMERIC(12,2) NOT NULL,
	total_amount NUMERIC(12, 2) GENERATED ALWAYS AS (quantity * price) STORED 
);
-- Example: Window Type Non-Inverter + Standard Cleaning
INSERT INTO services (service_aircon_type_id, service_categories_id) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 2);

-- Window Type Non-Inverter + Standard Cleaning
INSERT INTO service_price_tiers (services_id, capacity_range, price, sort_order) VALUES
(1, '0.5 - 1.0 HP', 600, 1),
(1, '1.5 - 2.5 HP', 700, 2);

-- Pulldown Deep Cleaning
INSERT INTO service_price_tiers (services_id, capacity_range, price, sort_order) VALUES
(2, '0.5 - 1.0 HP', 800, 1),
(2, '1.5 - 2.5 HP', 1000, 2);

/*
	1 booking → many employees
	1 employee → many bookings
	Calendar becomes employee-based*/

CREATE TABLE service_booking_technicians (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES service_bookings(id) ON DELETE CASCADE,
    admin_users_id INT NOT NULL REFERENCES admin_users(id),
    assigned_at TIMESTAMP DEFAULT NOW(),
    UNIQUE (booking_id, admin_users_id)
);

----------------------------------------------------------------------------------- end services booking ----------------------------------------------
 
SELECT 
    sat.name AS aircon_type,
    sc.service_name,
    s.id AS service_id,
    spt.capacity_range,
    spt.price
FROM service_aircon_type sat
JOIN services s 
    ON sat.id = s.service_aircon_type_id
JOIN service_categories sc
    ON sc.id = s.service_categories_id
JOIN service_price_tiers spt
    ON spt.services_id = s.id














