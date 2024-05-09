-- This query calculates the average time to purchase for each country
WITH FirstEvents AS (
    SELECT
        user_pseudo_id,  -- Unique identifier for each user
        country,  -- Country of the user
        FORMAT_DATE('%Y-%m-%d', PARSE_DATE('%Y%m%d', CAST(event_date AS STRING))) AS formatted_event_date,  -- Format the event date
        MIN(CASE WHEN event_name = 'page_view' THEN event_timestamp ELSE NULL END) AS first_page_view_time,  -- Time of first page view
        MIN(CASE WHEN event_name = 'purchase' THEN event_timestamp ELSE NULL END) AS first_purchase_time  -- Time of first purchase
    FROM
        `tc-da-1.turing_data_analytics.raw_events`
    WHERE
        event_name IN ('page_view', 'purchase')  -- Filter for page view and purchase events
    GROUP BY
        user_pseudo_id, event_date, country  -- Group by user, date, and country
)

SELECT
    country,  -- Country of the user
    AVG(TIMESTAMP_DIFF(TIMESTAMP_MICROS(first_purchase_time), TIMESTAMP_MICROS(first_page_view_time), MINUTE)) AS avg_time_to_purchase  -- Calculate average time to purchase in minutes
FROM
    FirstEvents
WHERE
    first_page_view_time IS NOT NULL AND
    first_purchase_time IS NOT NULL  -- Ensure valid timestamps for calculation
GROUP BY
    country  -- Group results by country
ORDER BY
    avg_time_to_purchase;  -- Order by average time for clarity