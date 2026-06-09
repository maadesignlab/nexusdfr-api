CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- ENUMS
-- =====================================================

CREATE TYPE publication_type AS ENUM (
    'BOOK',
    'MAGAZINE'
);

CREATE TYPE order_status AS ENUM (
    'PENDING',
    'COMPLETED',
    'CANCELLED'
);

CREATE TYPE reservation_status AS ENUM (
    'ACTIVE',
    'COMPLETED',
    'CANCELLED'
);

-- =====================================================
-- USERS
-- =====================================================

CREATE TABLE users (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL,

    email VARCHAR(255) NOT NULL UNIQUE,

    auth0_sub VARCHAR(255) UNIQUE,

    created_at TIMESTAMP DEFAULT NOW(),

    updated_at TIMESTAMP DEFAULT NOW()

);

-- =====================================================
-- CATEGORIES
-- =====================================================

CREATE TABLE categories (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(100) NOT NULL UNIQUE,

    slug VARCHAR(120) NOT NULL UNIQUE,

    created_at TIMESTAMP DEFAULT NOW()

);

-- =====================================================
-- AUTHORS
-- =====================================================

CREATE TABLE authors (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(150) NOT NULL,

    country VARCHAR(100),

    created_at TIMESTAMP DEFAULT NOW()

);

-- =====================================================
-- PUBLICATIONS
-- =====================================================

CREATE TABLE publications (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    title VARCHAR(255) NOT NULL,

    description TEXT,

    publication_type publication_type NOT NULL,

    price NUMERIC(10,2) NOT NULL,

    stock INTEGER NOT NULL DEFAULT 0,

    published_year INTEGER,

    isbn VARCHAR(50),

    publisher VARCHAR(150),

    pages INTEGER,

    cover_url TEXT,

    featured BOOLEAN DEFAULT FALSE,

    category_id UUID NOT NULL,

    created_at TIMESTAMP DEFAULT NOW(),

    updated_at TIMESTAMP DEFAULT NOW(),
    

    CONSTRAINT fk_publication_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE RESTRICT

);

-- =====================================================
-- PUBLICATION AUTHORS (N:M)
-- =====================================================

CREATE TABLE publication_authors (

    publication_id UUID NOT NULL,

    author_id UUID NOT NULL,

    PRIMARY KEY (
        publication_id,
        author_id
    ),

    CONSTRAINT fk_pa_publication
        FOREIGN KEY (publication_id)
        REFERENCES publications(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_pa_author
        FOREIGN KEY (author_id)
        REFERENCES authors(id)
        ON DELETE CASCADE

);

-- =====================================================
-- COWORKING SPACES
-- =====================================================

CREATE TABLE coworking_spaces (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(120) NOT NULL,

    capacity INTEGER NOT NULL CHECK (capacity > 0),

    space_type VARCHAR(50),

    location VARCHAR(100),

    available BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT NOW()

);

-- =====================================================
-- ORDERS
-- =====================================================

CREATE TABLE orders (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    total NUMERIC(10,2) NOT NULL DEFAULT 0,

    status order_status NOT NULL DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_order_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE

);

-- =====================================================
-- ORDER ITEMS
-- =====================================================

CREATE TABLE order_items (

    order_id UUID NOT NULL,

    publication_id UUID NOT NULL,

    quantity INTEGER NOT NULL CHECK (quantity > 0),

    unit_price NUMERIC(10,2) NOT NULL,

    subtotal NUMERIC(10,2) NOT NULL,

    PRIMARY KEY (
        order_id,
        publication_id
    ),

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_order_item_publication
        FOREIGN KEY (publication_id)
        REFERENCES publications(id)
        ON DELETE RESTRICT

);

-- =====================================================
-- RESERVATIONS
-- =====================================================

CREATE TABLE reservations (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    coworking_space_id UUID NOT NULL,

    start_at TIMESTAMP NOT NULL,

    end_at TIMESTAMP NOT NULL,

    status reservation_status NOT NULL DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_reservation_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_reservation_space
        FOREIGN KEY (coworking_space_id)
        REFERENCES coworking_spaces(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_reservation_dates
        CHECK (end_at > start_at)

);
