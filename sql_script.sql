-- Create the database
CREATE DATABASE lego;
GO

-- Switch to the newly created database
USE lego;
GO

-- Check tables in the database
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';


-- Removed non-matching part numbers from elements table
DELETE FROM elements
WHERE part_num NOT IN (SELECT part_num FROM parts);


/*
Which themes have a significantly
higher average part count than the company global average?

This query calculates how much the average part count
of a theme differs from the global average of all LEGO sets.
*/
WITH theme_metrics AS (
        SELECT t.name AS theme_name,
                s.set_num,
                s.num_parts,
                AVG(s.num_parts) OVER (PARTITION BY t.name) AS avg_theme_parts,
                AVG(s.num_parts) OVER() AS global_avg_parts
        FROM sets AS s
        JOIN themes AS t
        ON s.theme_id = t.id
)
SELECT DISTINCT theme_name,
        ROUND(avg_theme_parts, 0) AS avg_parts,
        ROUND(avg_theme_parts - global_avg_parts, 0) AS complexity_variance
FROM theme_metrics
WHERE avg_theme_parts > global_avg_parts
ORDER BY complexity_variance DESC;


/*
Which specific parts are considered high-risk
because they only appear in a single set?

I identified parts that appear only in one set inventory.
They are over 25,000 in number, which represent about 40% of all parts.
*/

SELECT p.part_num,
        p.name AS part_name,
        COUNT(DISTINCT s.set_num) AS set_appearance_count
FROM parts AS p
JOIN inventory_parts AS ip
        ON p.part_num = ip.part_num
JOIN inventories AS i
        ON ip.inventory_id = i.id
JOIN sets AS s
        ON i.set_num = s.set_num
GROUP BY p.part_num, p.name
HAVING COUNT(DISTINCT s.set_num) = 1
ORDER BY p.part_num;

/*
Which themes are the most resource-heavy
based on their density of minifigures?

This query identifies which themes require
the most specialized character components.
*/
SELECT t.name AS theme_name,
        SUM(m.num_parts) AS total_minifig_parts
FROM themes AS t
JOIN sets AS s
        ON t.id = s.theme_id
JOIN inventories AS i
        ON s.set_num = i.set_num
JOIN inventory_minifigs AS im
        ON i.id = im.inventory_id
JOIN minifigs AS m
        ON im.fig_num = m.fig_num
WHERE t.id IN (
        SELECT id
        FROM themes
        WHERE parent_id IS NOT NULL
)
GROUP BY t.name
ORDER BY total_minifig_parts DESC;

/*
Which colors are currently inactive
and could be removed from production
to save warehouse space?

This query identifies colors that have
not been included in any set produced in the last decade
*/
SELECT c.name AS color_name,
        COUNT(DISTINCT ip.part_num) AS associated_part_count
FROM colors AS c
JOIN inventory_parts AS ip
        ON c.id = ip.color_id
WHERE c.id NOT IN (
        SELECT DISTINCT color_id
        FROM inventory_parts AS ip2
        JOIN inventories AS i2
                ON ip2.inventory_id = i2.id
        JOIN sets AS s2
                ON i2.set_num = s2.set_num
        WHERE s2.year >= 2016
)
GROUP BY c.name
ORDER BY associated_part_count DESC;

/*
How do inventory versions impact
the consistency of set data and part counts?

This query, using a lag window function, tracks changes
in the number of parts in a set when a new inventory version is released.
*/
WITH version_history AS (
        SELECT i.set_num,
                i.version,
                COUNT(ip.part_num) AS recorded_parts,
                LAG(COUNT(ip.part_num))
                        OVER (
                                PARTITION BY i.set_num ORDER BY i.version
                                ) AS previous_version_parts
        FROM inventories AS i
        JOIN inventory_parts AS ip
                ON i.id = ip.inventory_id
        GROUP BY i.set_num, i.version
)
SELECT set_num,
        version,
        recorded_parts,
        previous_version_parts,
        ABS(recorded_parts - previous_version_parts) AS absolute_part_count_change
FROM version_history
WHERE previous_version_parts IS NOT NULL
        AND recorded_parts <> previous_version_parts
ORDER BY absolute_part_count_change DESC;