create schema dim

create schema fact
--таблица измерения ДАТЫ

CREATE TABLE dim.date
AS
WITH dates AS (
    SELECT dd::date AS dt
    FROM generate_series
            ('2010-01-01'::timestamp
            , '2030-01-01'::timestamp
            , '1 day'::interval) dd
)
SELECT
    to_char(dt, 'YYYYMMDD')::int AS id,
    dt AS date,
    to_char(dt, 'YYYY-MM-DD') AS ansi_date,
    date_part('isodow', dt)::int AS day,
    date_part('week', dt)::int AS week_number,
    date_part('month', dt)::int AS month,
    date_part('isoyear', dt)::int AS year,
    (date_part('isodow', dt)::smallint BETWEEN 1 AND 5)::int AS week_day,
    (to_char(dt, 'YYYYMMDD')::int IN (
        20130101,
        20130102,
        20130103,
        20130104,
        20130105,
        20130106,
        20130107,
        20130108,
        20130223,
        20130308,
        20130310,
        20130501,
        20130502,
        20130503,
        20130509,
        20130510,
        20130612,
        20131104,
        20140101,
        20140102,
        20140103,
        20140104,
        20140105,
        20140106,
        20140107,
        20140108,
        20140223,
        20140308,
        20140310,
        20140501,
        20140502,
        20140509,
        20140612,
        20140613,
        20141103,
        20141104,
        20150101,
        20150102,
        20150103,
        20150104,
        20150105,
        20150106,
        20150107,
        20150108,
        20150109,
        20150223,
        20150308,
        20150309,
        20150501,
        20150504,
        20150509,
        20150511,
        20150612,
        20151104,
        20160101,
        20160102,
        20160103,
        20160104,
        20160105,
        20160106,
        20160107,
        20160108,
        20160222,
        20160223,
        20160307,
        20160308,
        20160501,
        20160502,
        20160503,
        20160509,
        20160612,
        20160613,
        20161104,
        20170101,
        20170102,
        20170103,
        20170104,
        20170105,
        20170106,
        20170107,
        20170108,
        20170223,
        20170224,
        20170308,
        20170501,
        20170508,
        20170509,
        20170612,
        20171104,
        20171106,
        20180101,
        20180102,
        20180103,
        20180104,
        20180105,
        20180106,
        20180107,
        20180108,
        20180223,
        20180308,
        20180309,
        20180430,
        20180501,
        20180502,
        20180509,
        20180611,
        20180612,
        20181104,
        20181105,
        20181231,
        20190101,
        20190102,
        20190103,
        20190104,
        20190105,
        20190106,
        20190107,
        20190108,
        20190223,
        20190308,
        20190501,
        20190502,
        20190503,
        20190509,
        20190510,
        20190612,
        20191104,
        20200101, 20200102, 20200103, 20200106, 20200107, 20200108,
       20200224, 20200309, 20200501, 20200504, 20200505, 20200511,
       20200612, 20201104))::int AS holiday
FROM dates
ORDER BY dt;

ALTER TABLE dim.date ADD PRIMARY KEY (id);


--таблица измерения ПАССАЖИРЫ

CREATE TABLE dim.passenger (
	passenger_id varchar(30) primary key,
	passenger_name text NOT NULL,
	email varchar(300) null,
	phone varchar(300) null)


--таблица измерения САМОЛЕТЫ

CREATE TABLE dim.aircrafts  (
	aircraft_code bpchar(3) primary key,
	model text NOT NULL,
	"range" int4 NOT NULL)


--таблица измерения АЭРОПОРТЫ
CREATE TABLE dim.airports  (
	airport_code bpchar(3) primary key,
	airport_name text NOT NULL,
	city text NOT NULL,
	longitude float8 NOT NULL,
	latitude float8 NOT NULL,
	timezone text NOT NULL)


--таблица измерения ТАРИФЫ
CREATE TABLE dim.tariff  (
	ticket_no bpchar(13),
	flight_id int4,
	fare_conditions varchar(10) NOT NULL,
	amount numeric(10, 2) NOT null,
	CONSTRAINT tariff_pkey PRIMARY KEY (ticket_no, flight_id),
	CONSTRAINT tariff_fare_conditions_check CHECK (((fare_conditions)::text = ANY (ARRAY[('Economy'::character varying)::text, ('Comfort'::character varying)::text, ('Business'::character varying)::text]))))

	
--таблица фактов

CREATE TABLE fact.flights (
   	passenger_id varchar(30) not null references dim.passenger(passenger_id),
	date_dep timestamp not null,
	date_arr timestamp not null,
	diff_dep int not null,
	diff_arr int not null,
	model text not null references dim.aircrafts(aircraft_code),
	airport_dep bpchar(3) not null references dim.airports(airport_code),
	airport_arr bpchar(3) not null references dim.airports(airport_code),
	fare_condition varchar(10) not null,
	amount numeric(10, 2) not null)

