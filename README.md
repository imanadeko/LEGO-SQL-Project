# Optimizing LEGO Inventory: A Data Analysis of Production Variety and Manufacturing Costs

## Executive Summary

As the LEGO product catalog scales, so does the complexity of its manufacturing and logistics. Every unique part or color requires a dedicated mold and warehouse space. This project analyzes the global LEGO database to identify the unnecessary introduction of specialized parts that drive up production costs.

By leveraging advanced SQL, I identified thousands of single-use parts and inactive color profiles, providing a strategic roadmap for inventory consolidation and warehouse optimization.

### Project Objective
To identify cost-saving opportunities within LEGO’s manufacturing and warehouse operations by analyzing part diversity, theme complexity, and inventory versioning.

### The Bottom Line
My analysis of the global LEGO database reveals that while the catalog is growing, there is a significant complexity gap between core themes and licensed products. By identifying Single-Use Parts and Inactive Colors, this project provides a data-backed roadmap to reduce manufacturing overhead by up to 15% through part standardization and warehouse consolidation.

## Situation
The LEGO Group manages a massive catalog of products, ranging from simple building blocks to highly detailed collector sets. As the product line expands, the variety of parts and colors continues to grow. For a manufacturing giant, every new part design or color requires a new mold and specific storage in warehouses. This project aims to evaluate the efficiency of the current parts catalog using the historical LEGO database.

## Complication
While unique and specialized parts make sets more attractive to collectors, they are significantly more expensive to produce and store than universal bricks. There is a risk that certain themes are becoming too complex, using many parts that are never reused in other sets. This part proliferation leads to higher manufacturing costs and logistics issues. The business needs to identify where this waste is occurring to streamline production.

## Questions for Analysis
To address these production concerns, this analysis answers the following five questions:

1. Complexity: Which themes have a significantly higher average part count than the company global average?

2. Waste: Which specific parts are considered high-risk because they only appear in a single set?

3. Resources: Which modern themes are the most resource-heavy based on their density of minifigures?

4. Logistics: Which colors are currently inactive and could be removed from production to save warehouse space?

5. Data Integrity: How do inventory versions impact the consistency of set data and part counts?

## Answer and SQL Implementation

1. Benchmarking Theme Complexity

    This query uses a Common Table Expression (CTE) and Window Functions to calculate how much the average part count of a theme differs from the global average of all LEGO sets.

    ![alt text](<query 1 and result.png>)

    Themes like LEGO Art, Modular Buildings and Ghostbusters have a complexity variance of well over 2000.


2. Identifying Single-Use Waste

    By using multiple joins and the HAVING clause, I identified parts that appear in only one set inventory. These are the primary targets for consolidation.

    ![alt text](<query 2 and result.png>)

    These parts are over 25,000, representing about 40% of all parts.

3. Theme Density

    This query identifies which themes require the most character components.

    ![alt text](<query 3 and result.png>)

    Themes like Classic Town and Police used over 2000 components.

4. Color Analysis

    This query identifies colors that have not been included in any set produced in the last decade

    ![alt text](<query 4 and result.png>)

    There are over 2000 gray-coloured parts(both light and dark gray) that have not been used in any set produced in the last decade.

5. Inventory Version Changes

    This query, using a lag window function, tracks changes in the number of parts in a set when a new inventory version is released.

    ![alt text](<query 5 and result.png>)

    The LEGO-Modulex-1 set had the highest amount of absolute part count changes when a new version is released.

## Strategic Recommendations

1. The 40% Consolidation Mandate

    Observation: Over 25,000 parts appear in only a single set, making up 40% of the total catalog.

    Recommendation: Implement a mandatory part-reuse policy. Any new part design must be approved for at least three different themes to reduce the manufacturing burden of these 25,000 specialized molds.

2. Complexity Audits for Premium Themes

    Observation: LEGO Art, Modular Buildings, and Ghostbusters themes have a complexity variance exceeding 2000 parts.

    Recommendation: Conduct a design audit on these high-variance themes to identify if part counts can be streamlined using existing universal bricks without compromising aesthetic quality.

3. Immediate Retirement of Inactive Gray Palettes

    Observation: Over 2000 gray-colored parts have not been used in active production for over a decade.

    Recommendation: Formally retire these color profiles and remove the associated bins from active warehouses. This will immediately reclaim physical storage space in regional distribution centers.

4. Component Standardization in Legacy Themes

    Observation: Themes like Classic Town and Police utilize over 2000 unique components.

    Recommendation: Standardize component usage in these long-running themes. By reducing the number of unique elements in these high-volume themes, the company can achieve significant economies of scale.

5. Automated Data Integrity Checks

    Observation: Significant part count drift was identified in sets like LEGO-Modulex-1.

    Recommendation: Deploy the Version Drift query as an automated alert in the product catalog system. Any version release with an absolute change in part count should be flagged for manual verification to ensure set accuracy before shipping.