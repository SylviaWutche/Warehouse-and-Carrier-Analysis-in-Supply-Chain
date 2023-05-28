/* IDENTIFY TOP PERFORMING CARRIERS FOR EACH SERVICE LEVEL */

SELECT 
    ol.Carrier,
    ol.Service_Level,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN ol.Ship_Late_Day_count > 0 THEN 1
        ELSE 0
    END) AS late_orders,
    SUM(CASE
        WHEN ol.Ship_Late_Day_count = 0 THEN 1
        ELSE 0
    END) AS ontime_orders,
    FORMAT((SUM(CASE
            WHEN ol.Ship_Late_Day_count = 0 THEN 1
            ELSE 0
        END) / COUNT(*)),
        3) * 100 AS ontime_delivery_percentage
FROM
    orderlist AS ol
        JOIN
    freightrates AS fr ON ol.Carrier = fr.Carrier
        AND ol.Destination_Port = dest_port_cd
GROUP BY ol.Carrier , ol.Service_Level
ORDER BY ontime_delivery_percentage DESC;


/* IDENTIFY THE MOST COST_EFFECTIVE CARRIER */

SELECT 
    ol.Carrier,
    SUM(ol.Weight * fr.rate) AS total_cost,
    COUNT(*) AS total_orders,
    SUM(ol.TPT) AS total_throughput_time,
    (SUM(ol.Weight * fr.rate) / SUM(TPT)) AS cost_efficiency
FROM
    orderlist AS ol
        JOIN
    freightrates AS fr ON ol.Carrier = fr.Carrier
GROUP BY ol.Carrier
ORDER BY cost_efficiency DESC;


/* PERFORMANCE OF CARRIER BASED ON SHIPMENT VOLUME AND MARKET SHARE */

SELECT 
    Carrier,
    COUNT(*) AS shipment_count,
    COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            orderlist) * 100 AS market_share
FROM
    orderlist
GROUP BY Carrier
ORDER BY shipment_count DESC;


/* OPTIMIZING WAREHOUSE CAPACITY ALLOCATION */

SELECT 
    wc.plant_id,
    wc.Daily_Capacity,
    COUNT(ol.Order_ID) AS orders_assigned,
    FORMAT((COUNT(ol.Order_ID) / wc.Daily_Capacity * 100),
        2) AS utilization_rate
FROM
    whcapacities wc
        LEFT JOIN
    orderlist AS ol ON wc.Plant_ID = ol.Plant_Code
GROUP BY wc.Plant_ID , wc.Daily_Capacity
ORDER BY utilization_rate DESC;


/* ANALYZING STORAGE COST ON WAREHOUSES */

SELECT 
    whc.Plant_ID,
    COUNT(ol.Product_ID) AS No_of_products,
    SUM(whc.Daily_Capacity) AS total_capacity,
    SUM(ol.Unit_quantity * wc.cost_per_unit) AS total_storage_cost
FROM
    whcapacities whc
        JOIN
    whcosts wc ON whc.Plant_ID = wc.WH
        JOIN
    orderlist ol ON ol.Plant_Code = wc.WH
GROUP BY whc.Plant_ID
ORDER BY total_storage_cost DESC;



