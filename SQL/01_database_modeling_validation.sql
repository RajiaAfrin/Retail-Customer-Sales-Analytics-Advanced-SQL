--Database modeling and validat
DROP TABLE IF EXISTS transaction_data;
CREATE TABLE transaction_data (
    household_key      INTEGER,
    basket_id          BIGINT,
    day                INTEGER,
    product_id         INTEGER,
    quantity           INTEGER,
    sales_value        NUMERIC(10,2),
    store_id           INTEGER,
    retail_disc        NUMERIC(10,2),
    trans_time         INTEGER,
    week_no            INTEGER,
    coupon_disc        NUMERIC(10,2),
    coupon_match_disc  NUMERIC(10,2)
);
SELECT COUNT(*)
FROM transaction_data;

SELECT
    basket_id,
    product_id,
    COUNT(*) AS duplicate_count
FROM transaction_data
GROUP BY
    basket_id,
    product_id
HAVING COUNT(*) > 1;
SELECT *
FROM transaction_data
WHERE basket_id IS NULL
   OR product_id IS NULL;
   
ALTER TABLE transaction_data
ADD CONSTRAINT pk_transaction_data
PRIMARY KEY (basket_id, product_id);go

DROP TABLE IF EXISTS product;

CREATE TABLE product (
    product_id            INTEGER,
    manufacturer          INTEGER,
    department            TEXT,
    brand                 TEXT,
    commodity_desc        TEXT,
    sub_commodity_desc    TEXT,
    curr_size_of_product  TEXT
);

SELECT COUNT(*)
FROM product;

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM product
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT *
FROM product
WHERE product_id IS NULL;

ALTER TABLE product
ADD CONSTRAINT pk_product
PRIMARY KEY (product_id);

DROP TABLE IF EXISTS hh_demographic;

CREATE TABLE hh_demographic (
    age_desc              TEXT,
    marital_status_code   TEXT,
    income_desc           TEXT,
    homeowner_desc        TEXT,
    hh_comp_desc          TEXT,
    household_size_desc   TEXT,
    kid_category_desc     TEXT,
    household_key         INTEGER
);
SELECT COUNT(*)
FROM hh_demographic;

SELECT
    household_key,
    COUNT(*) AS duplicate_count
FROM hh_demographic
GROUP BY household_key
HAVING COUNT(*) > 1;

SELECT *
FROM hh_demographic
WHERE household_key IS NULL;

ALTER TABLE hh_demographic
ADD CONSTRAINT pk_hh_demographic
PRIMARY KEY (household_key);

DROP TABLE IF EXISTS campaign_desc;

CREATE TABLE campaign_desc (
    description TEXT,
    campaign    INTEGER,
    start_day   INTEGER,
    end_day     INTEGER
);

SELECT COUNT(*)
FROM campaign_desc;

SELECT
    campaign,
    COUNT(*) AS duplicate_count
FROM campaign_desc
GROUP BY campaign
HAVING COUNT(*) > 1;

SELECT *
FROM campaign_desc
WHERE campaign IS NULL;

ALTER TABLE campaign_desc
ADD CONSTRAINT pk_campaign_desc
PRIMARY KEY (campaign);

DROP TABLE IF EXISTS campaign_table;
CREATE TABLE campaign_table (
    description   TEXT,
    household_key INTEGER,
    campaign      INTEGER
);

SELECT COUNT(*)
FROM campaign_table;

SELECT
    household_key,
    campaign,
    COUNT(*) AS duplicate_count
FROM campaign_table
GROUP BY household_key, campaign
HAVING COUNT(*) > 1;

SELECT *
FROM campaign_table
WHERE household_key IS NULL
   OR campaign IS NULL;

ALTER TABLE campaign_table
ADD CONSTRAINT pk_campaign_table
PRIMARY KEY (household_key, campaign);

ALTER TABLE transaction_data
ADD CONSTRAINT fk_transaction_product
FOREIGN KEY (product_id)
REFERENCES product(product_id);

ALTER TABLE campaign_table
ADD CONSTRAINT fk_campaign_desc
FOREIGN KEY (campaign)
REFERENCES campaign_desc(campaign);

DROP TABLE IF EXISTS coupon;

CREATE TABLE coupon (
    coupon_upc BIGINT,
    product_id INTEGER,
    campaign INTEGER
);

SELECT COUNT(*)
FROM coupon;

SELECT
    coupon_upc,
    product_id,
    campaign,
    COUNT(*) AS duplicate_count
FROM coupon
GROUP BY
    coupon_upc,
    product_id,
    campaign
HAVING COUNT(*) > 1;

SELECT *
FROM coupon
WHERE coupon_upc = 54180010033
  AND product_id = 91572
  AND campaign = 13;
  
SELECT *
FROM coupon
WHERE coupon_upc IS NULL
   OR product_id IS NULL
   OR campaign IS NULL;
   
SELECT COUNT(*)
FROM coupon c
LEFT JOIN product p
ON c.product_id = p.product_id
WHERE p.product_id IS NULL;

ALTER TABLE coupon
ADD CONSTRAINT fk_coupon_product
FOREIGN KEY (product_id)
REFERENCES product(product_id);

SELECT COUNT(*)
FROM coupon c
LEFT JOIN campaign_desc cd
ON c.campaign = cd.campaign
WHERE cd.campaign IS NULL;

ALTER TABLE coupon
ADD CONSTRAINT fk_coupon_campaign
FOREIGN KEY (campaign)
REFERENCES campaign_desc(campaign);

DROP TABLE IF EXISTS coupon_redempt;

CREATE TABLE coupon_redempt (
    household_key INTEGER,
    day INTEGER,
    coupon_upc BIGINT,
    campaign INTEGER
);

SELECT COUNT(*)
FROM coupon_redempt;

SELECT
    household_key,
    coupon_upc,
    campaign,
    COUNT(*) AS duplicate_count
FROM coupon_redempt
GROUP BY
    household_key,
    coupon_upc,
    campaign
HAVING COUNT(*) > 1;
SELECT *
FROM coupon_redempt
WHERE household_key = 1228
  AND coupon_upc = 54900050076
  AND campaign = 18;

SELECT
    household_key,
    coupon_upc,
    campaign,
    day,
    COUNT(*) AS duplicate_count
FROM coupon_redempt
GROUP BY
    household_key,
    coupon_upc,
    campaign,
    day
HAVING COUNT(*) > 1;

ALTER TABLE coupon_redempt
ADD CONSTRAINT pk_coupon_redempt
PRIMARY KEY (household_key, coupon_upc, campaign, day);

SELECT COUNT(*)
FROM coupon_redempt cr
LEFT JOIN hh_demographic h
ON cr.household_key = h.household_key
WHERE h.household_key IS NULL;

SELECT COUNT(*)
FROM coupon_redempt cr
LEFT JOIN campaign_desc cd
ON cr.campaign = cd.campaign
WHERE cd.campaign IS NULL;

ALTER TABLE coupon_redempt
ADD CONSTRAINT fk_coupon_redempt_campaign
FOREIGN KEY (campaign)
REFERENCES campaign_desc(campaign);

DROP TABLE IF EXISTS causal_data;

CREATE TABLE causal_data (
    product_id INTEGER,
    store_id INTEGER,
    week_no INTEGER,
    display TEXT,
    mailer TEXT
);

SELECT COUNT(*)
FROM causal_data;

SELECT *
FROM causal_data
LIMIT 10;

ALTER TABLE causal_data
ADD CONSTRAINT pk_causal_data
PRIMARY KEY (product_id, store_id, week_no);

SELECT *
FROM causal_data
WHERE product_id = 27658
  AND store_id = 361
  AND week_no = 59;

ALTER TABLE causal_data
ADD CONSTRAINT pk_causal_data
PRIMARY KEY (product_id, store_id, week_no, display);

SELECT *
FROM causal_data
WHERE product_id = 262910
  AND store_id = 330
  AND week_no = 77
  AND display = '5';

SELECT
    product_id,
    store_id,
    week_no,
    display,
    mailer,
    COUNT(*) AS duplicate_count
FROM causal_data
GROUP BY
    product_id,
    store_id,
    week_no,
    display,
    mailer
HAVING COUNT(*) > 1
LIMIT 10;

SELECT *
FROM causal_data
WHERE product_id IS NULL
   OR store_id IS NULL
   OR week_no IS NULL
   OR display IS NULL
   OR mailer IS NULL
LIMIT 10;

ALTER TABLE causal_data
ADD CONSTRAINT pk_causal_data
PRIMARY KEY (
    product_id,
    store_id,
    week_no,
    display,
    mailer
);

SELECT COUNT(*)
FROM causal_data cd
LEFT JOIN product p
ON cd.product_id = p.product_id
WHERE p.product_id IS NULL;

ALTER TABLE causal_data
ADD CONSTRAINT fk_causal_data_product
FOREIGN KEY (product_id)
REFERENCES product(product_id);

