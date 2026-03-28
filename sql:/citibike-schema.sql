

-- Create Date Dimension Table
CREATE TABLE DateDim (
    date_id INT PRIMARY KEY,
    date_value DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    weekday_name NVARCHAR(10),
    is_weekend BIT,
    is_holiday BIT DEFAULT 0
);

-- Insert dates for October 2025
DECLARE @d DATE = '2025-10-01';

WHILE @d <= '2025-10-31'
BEGIN
    INSERT INTO DateDim (date_id, date_value, day, month, year, weekday_name, is_weekend)
    VALUES (
        CAST(FORMAT(@d, 'yyyyMMdd') AS INT),
        @d,
        DAY(@d),
        MONTH(@d),
        YEAR(@d),
        DATENAME(WEEKDAY, @d),
        CASE WHEN DATENAME(WEEKDAY, @d) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END
    );

    SET @d = DATEADD(DAY, 1, @d);
END;

-- Create Station Feedback / Maintenance Form Table
CREATE TABLE StationForm (
    form_id INT IDENTITY(1,1) PRIMARY KEY,      -- unique form submission ID
    station_id VARCHAR(10) NOT NULL,            -- FK to StationDim
    report_date DATETIME2 DEFAULT GETDATE(),    -- when the feedback was submitted
    issue_type NVARCHAR(50),                     -- e.g., 'Maintenance', 'User Feedback', 'Safety'
    description NVARCHAR(500),                  -- details of the issue
    reported_by NVARCHAR(50),                   -- name or user type of reporter
    status NVARCHAR(20) DEFAULT 'Open'          -- 'Open', 'In Progress', 'Resolved'
);

ALTER TABLE StationForm
ALTER COLUMN station_id VARCHAR(50) NOT NULL;

ALTER TABLE StationForm
ADD CONSTRAINT FK_StationForm_dimStation
FOREIGN KEY (station_id)
REFERENCES dim_station(station_id);

SELECT COUNT(DISTINCT start_station_id) AS distinct_start_stations,
       COUNT(DISTINCT end_station_id) AS distinct_end_stations
FROM CitiBikeRides;

-- Get all unique station IDs and names from both start and end stations
SELECT DISTINCT station_id, station_name, latitude, longitude
FROM (
    SELECT start_station_id AS station_id,
           start_station_name AS station_name,
           start_lat AS latitude,
           start_lng AS longitude
    FROM CitiBikeRides
    UNION
    SELECT end_station_id AS station_id,
           end_station_name AS station_name,
           end_lat AS latitude,
           end_lng AS longitude
    FROM CitiBikeRides
) AS all_stations
ORDER BY station_id;

-- Insert unique, non-null stations into dim_station
WITH all_stations AS (
    SELECT start_station_id AS station_id,
           LTRIM(RTRIM(start_station_name)) AS station_name,
           start_lat AS latitude,
           start_lng AS longitude
    FROM CitiBikeRides
    WHERE start_station_id IS NOT NULL
      AND start_station_name IS NOT NULL

    UNION ALL

    SELECT end_station_id AS station_id,
           LTRIM(RTRIM(end_station_name)) AS station_name,
           end_lat AS latitude,
           end_lng AS longitude
    FROM CitiBikeRides
    WHERE end_station_id IS NOT NULL
      AND end_station_name IS NOT NULL
),
deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY station_id ORDER BY station_name) AS rn
    FROM all_stations
)
INSERT INTO dim_station (station_id, station_name, latitude, longitude)
SELECT station_id, station_name, latitude, longitude
FROM deduped
WHERE rn = 1;

-- Create a cleaned version of CitiBikeRides
SELECT *
INTO CitiBikeRides_clean
FROM CitiBikeRides
WHERE start_station_id IS NOT NULL
  AND end_station_id IS NOT NULL
  AND started_at IS NOT NULL
  AND ended_at IS NOT NULL
  AND DATEDIFF(MINUTE, started_at, ended_at) > 0;

-- Check for any start stations in fact table missing in dim_station
SELECT DISTINCT start_station_id
FROM CitiBikeRides_clean c
WHERE NOT EXISTS (
    SELECT 1 
    FROM dim_station s
    WHERE c.start_station_id = s.station_id
);

-- Check for any end stations in fact table missing in dim_station
SELECT DISTINCT end_station_id
FROM CitiBikeRides_clean c
WHERE NOT EXISTS (
    SELECT 1 
    FROM dim_station s
    WHERE c.end_station_id = s.station_id
);

ALTER TABLE StationForm
DROP CONSTRAINT FK_StationForm_dimStation;
ALTER TABLE dim_station
DROP CONSTRAINT PK__dim_stat__44B370E998E6EAC5;
ALTER TABLE dim_station
ALTER COLUMN station_id NVARCHAR(50) NOT NULL;
ALTER TABLE dim_station
ADD CONSTRAINT PK_dim_station PRIMARY KEY (station_id);



ALTER TABLE StationForm
DROP CONSTRAINT IF EXISTS FK_StationForm_dimStation;

ALTER TABLE StationForm
ALTER COLUMN station_id NVARCHAR(50) NOT NULL;
ALTER TABLE StationForm
ADD CONSTRAINT FK_StationForm_dimStation
FOREIGN KEY (station_id) REFERENCES dim_station(station_id);
-- Check for orphaned start stations
SELECT DISTINCT start_station_id
FROM CitiBikeRides_clean
WHERE start_station_id NOT IN (SELECT station_id FROM dim_station);

-- Check for orphaned end stations
SELECT DISTINCT end_station_id
FROM CitiBikeRides_clean
WHERE end_station_id NOT IN (SELECT station_id FROM dim_station);
-- Check for orphaned stations in StationForm
SELECT DISTINCT station_id
FROM StationForm
WHERE station_id NOT IN (SELECT station_id FROM dim_station);


SELECT DISTINCT station_name
FROM dim_station
ORDER BY station_name;

-- Get a random sample of 50 stations
SELECT TOP 50 *
FROM dim_station
ORDER BY NEWID();

ALTER TABLE StationForm
ADD station_name NVARCHAR(200);
EXEC sp_help 'StationForm';

SELECT station_id FROM dim_station ORDER BY station_id;

INSERT INTO dbo.StationForm 
(station_id, report_date, issue_type, description, reported_by, status)
VALUES
('1234.56', '2024-10-01', 'Docking Issue', 'Dock 3 not locking properly.', 'Alex', 'Open'),
('2533.04', '2024-10-02', 'Bike Availability', 'No bikes available during morning rush.', 'Jordan', 'Open'),
('2578.16', '2024-10-02', 'Maintenance Needed', 'Station needs cleaning and trash removal.', 'Priya', 'In Progress'),
('2635.08', '2024-10-03', 'Docking Issue', 'Two docks showing red light error.', 'Sam', 'Resolved'),
('2660.09', '2024-10-03', 'Payment / Kiosk Issue', 'Kiosk touchscreen unresponsive.', 'Taylor', 'Open'),

('2698.07', '2024-10-04', 'Docking Issue', 'Bikes not locking in rows 2–4.', 'Michael', 'In Progress'),
('2708.07', '2024-10-04', 'Bike Availability', 'Only 1 bike available at 6 PM.', 'Sara', 'Open'),
('2717.06', '2024-10-05', 'Maintenance Needed', 'Graffiti on side panel.', 'Chris', 'Resolved'),
('2733.03', '2024-10-05', 'Docking Issue', 'Dock 7 jammed.', 'Riya', 'Open'),
('2743.04', '2024-10-05', 'Other', 'User reported strange noise from multiple bikes.', 'Leo', 'Open'),

('2782.02', '2024-10-06', 'Bike Availability', 'Weekend spike, empty station.', 'Maya', 'In Progress'),
('2793.07', '2024-10-06', 'Bike Availability', 'Low availability across morning.', 'Hector', 'Open'),
('2821.05', '2024-10-07', 'Signage / Information', 'Instruction panel is loose.', 'Daniel', 'Resolved'),
('2832.03', '2024-10-07', 'Maintenance Needed', 'Light bulb not working.', 'Chloe', 'In Progress'),
('2843.01', '2024-10-07', 'Docking Issue', 'Dock 1 frozen.', 'Ava', 'Open'),

('2843.13', '2024-10-08', 'Bike Availability', 'Not enough bikes for commuters.', 'Zara', 'Open'),
('2861.02', '2024-10-08', 'Payment / Kiosk Issue', 'Declines multiple card types.', 'John', 'In Progress'),
('2872.02', '2024-10-09', 'Maintenance Needed', 'Loose wiring visible.', 'Liam', 'Open'),
('2883.03', '2024-10-09', 'Docking Issue', 'Dock sensor flashing.', 'Emma', 'Resolved'),
('2898.01', '2024-10-09', 'Other', 'Customer complaint about squeaky bikes.', 'Kai', 'Open'),

('2912.08', '2024-10-10', 'Docking Issue', 'Red light errors on multiple docks.', 'Alex', 'In Progress'),
('2923.01', '2024-10-10', 'Bike Availability', 'Afternoon shortage reported.', 'Jordan', 'Open'),
('2932.03', '2024-10-11', 'Maintenance Needed', 'Station platform dirty.', 'Priya', 'Resolved'),
('2942.07', '2024-10-11', 'Signage / Information', 'Map panel cracked.', 'Sam', 'Open'),
('2947.05', '2024-10-11', 'Docking Issue', 'Bike stuck in dock 5.', 'Taylor', 'Open'),

('2951.05', '2024-10-12', 'Bike Availability', 'Weekend surge caused shortages.', 'Michael', 'Open'),
('2961.05', '2024-10-12', 'Payment / Kiosk Issue', 'QR code not scanning.', 'Sara', 'In Progress'),
('2971.02', '2024-10-12', 'Maintenance Needed', 'Loose bolts spotted.', 'Chris', 'Open'),
('2981.03', '2024-10-13', 'Docking Issue', 'Dock row unresponsive.', 'Riya', 'Resolved'),
('2984.04', '2024-10-13', 'Other', 'Unusual burning smell reported.', 'Leo', 'Open'),

('2996.05', '2024-10-14', 'Docking Issue', 'Another red light error.', 'Maya', 'Open'),
('3000.08', '2024-10-14', 'Bike Availability', 'Peak hour shortage.', 'Hector', 'In Progress'),
('3007.05', '2024-10-15', 'Maintenance Needed', 'Panel hinge broken.', 'Daniel', 'Resolved'),
('3011.03', '2024-10-15', 'Docking Issue', 'Dock 9 acting unstable.', 'Chloe', 'Open'),
('3019.02', '2024-10-15', 'Bike Availability', 'Only 2 bikes left at 5 PM.', 'Ava', 'Open'),

('3019.03', '2024-10-16', 'Docking Issue', 'Bike half-locked.', 'Zara', 'In Progress'),
('3022.01', '2024-10-16', 'Payment / Kiosk Issue', 'System reboot loop.', 'John', 'Open'),
('3034.02', '2024-10-17', 'Maintenance Needed', 'Lighting panel flickering.', 'Liam', 'Open'),
('3038.08', '2024-10-17', 'Docking Issue', 'Row 3 offline.', 'Emma', 'Resolved'),
('3046.03', '2024-10-17', 'Other', 'Vandalism reported.', 'Kai', 'Open'),

('3050.03', '2024-10-18', 'Bike Availability', 'Morning empty.', 'Alex', 'Open'),
('3056.05', '2024-10-18', 'Docking Issue', 'Recurring dock sensor error.', 'Jordan', 'In Progress'),
('3056.07', '2024-10-19', 'Maintenance Needed', 'Dust buildup noticed.', 'Priya', 'Resolved'),
('3070.04', '2024-10-19', 'Signage / Information', 'Faded instructions.', 'Sam', 'Open'),
('3080.01', '2024-10-19', 'Docking Issue', 'Dock arm stuck.', 'Taylor', 'Open'),

('3084.05', '2024-10-20', 'Bike Availability', 'Weekend shortage again.', 'Michael', 'In Progress'),
('3087.01', '2024-10-20', 'Docking Issue', 'Multiple docks offline.', 'Sara', 'Open'),
('3090.06', '2024-10-21', 'Payment / Kiosk Issue', 'Pin pad not working.', 'Chris', 'Resolved'),
('3093.07', '2024-10-22', 'Maintenance Needed', 'Loose screw on panel.', 'Riya', 'Open'),
('3099.01', '2024-10-23', 'Docking Issue', 'Full dock row error.', 'Leo', 'Open');

ALTER TABLE [dbo].[StationForm]
DROP COLUMN station_name;

ALTER TABLE [dbo].[StationForm]
DROP COLUMN status;
ALTER TABLE [dbo].[StationForm]
DROP CONSTRAINT DF__StationFo__statu__6E01572D;

ALTER TABLE [dbo].[StationForm]
ADD station_name NVARCHAR(50) NULL;