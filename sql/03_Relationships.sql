-- Foreign Key Between Product Table & categoryTranslation table
ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (product_category_name)
REFERENCES category_translation(product_category_name);

-- Make Sure The Connection Is Done
SELECT
    constraint_name,
    table_name
FROM information_schema.table_constraints
WHERE table_name = 'products'
  AND constraint_type = 'FOREIGN KEY';