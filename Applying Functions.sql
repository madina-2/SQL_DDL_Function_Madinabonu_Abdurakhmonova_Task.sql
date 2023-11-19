-- Drop view sales_revenue_by_category_qtr if it exists
DROP VIEW IF EXISTS sales_revenue_by_category_qtr;

-- Create view sales_revenue_by_category_qtr
CREATE VIEW sales_revenue_by_category_qtr AS
SELECT
    c.name AS category,
    SUM(p.amount) AS revenue
FROM
    payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film_category fc ON i.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
WHERE
    DATE_TRUNC('quarter', p.payment_date) = DATE_TRUNC('quarter', CURRENT_DATE)
GROUP BY
    c.category_id
HAVING
    SUM(p.amount) > 0;

-- Create query language function get_sales_revenue_by_category_qtr
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(current_quarter TIMESTAMP)
RETURNS TABLE (category TEXT, revenue NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM sales_revenue_by_category_qtr
    WHERE DATE_TRUNC('quarter', payment_date) = DATE_TRUNC('quarter', current_quarter);
END;
$$ LANGUAGE plpgsql;

-- Create procedure language function new_movie
CREATE OR REPLACE FUNCTION new_movie(movie_title TEXT)
RETURNS VOID AS $$
DECLARE
    new_film_id INTEGER;
    language_id INTEGER;
BEGIN
    -- Generate new unique film ID
    SELECT MAX(film_id) + 1 INTO new_film_id FROM film;

    -- Verify that the language exists in the language table
    SELECT language_id INTO language_id FROM language WHERE name = 'Klingon';

    -- Insert new movie with given title in the film table
    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, movie_title, 4.99, 3, 19.99, DATE_PART('year', CURRENT_DATE), language_id)
    ON CONFLICT (film_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;
