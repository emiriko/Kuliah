--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.26
-- Dumped by pg_dump version 11.17 (Debian 11.17-0+deb10u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: sirest; Type: SCHEMA; Schema: -; Owner: db22a003
--

CREATE SCHEMA sirest;


ALTER SCHEMA sirest OWNER TO db22a003;

--
-- Name: cek_saldo_penarikan_restopay(); Type: FUNCTION; Schema: sirest; Owner: db22a003
--

CREATE FUNCTION sirest.cek_saldo_penarikan_restopay() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
 BEGIN
  IF(NEW.RestoPay < OLD.RestoPay AND OLD.RestoPay - NEW.RestoPay > OLD.RestoPay) THEN
   RAISE EXCEPTION 'Nominal penarikan saldo tidak boleh melebihi jumlah saldo yang dimiliki saat ini';
  END IF;
  RETURN NEW;
 END;
$$;


ALTER FUNCTION sirest.cek_saldo_penarikan_restopay() OWNER TO db22a003;

--
-- Name: checkdeliveryfeeperkm(); Type: FUNCTION; Schema: sirest; Owner: db22a003
--

CREATE FUNCTION sirest.checkdeliveryfeeperkm() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 motorFee integer;
 carFee integer;
BEGIN
 motorFee := NEW.motorfee;
 carFee := NEW.carFee;

 IF(motorFee >= carFee) THEN
  RAISE EXCEPTION 'Biaya pengiriman dengan motor harus lebih rendah daripada biaya pengiriman dengan mobil';
 ELSIF ((motorFee not BETWEEN 2000 AND 7000) OR (carFee not BETWEEN 2000 AND 7000)) THEN
  RAISE EXCEPTION 'Harus berada diantara 2000 dan batas 7000';

 END IF;
 RETURN NEW;
END;
$$;


ALTER FUNCTION sirest.checkdeliveryfeeperkm() OWNER TO db22a003;

--
-- Name: deliveryprice(); Type: FUNCTION; Schema: sirest; Owner: db22a003
--

CREATE FUNCTION sirest.deliveryprice() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 mFee integer;
 cFee integer;
BEGIN
 SELECT MotorFee, CarFee INTO mFee, cFee
 FROM DELIVERY_FEE_PER_KM
 WHERE Id=NEW.DFId;

 IF (NEW.VehicleType='Car') THEN
  NEW.DeliveryFee = cFee * 2;
 ELSE
  NEW.DeliveryFee = mFee * 2;
 END IF;

 NEW.TotalPrice = NEW.TotalFood + NEW.DeliveryFee;

 RETURN NEW;
END;
$$;


ALTER FUNCTION sirest.deliveryprice() OWNER TO db22a003;

--
-- Name: menambah_restopay(); Type: FUNCTION; Schema: sirest; Owner: db22a003
--

CREATE FUNCTION sirest.menambah_restopay() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    biaya_pengantaran integer;
    total_harga_makanan integer;
    id_kurir text;
    email_restoran text;
BEGIN
    IF(NEW.name = 'Pesanan Selesai') THEN
        SELECT tr.deliveryFee, (tr.totalprice - tr.deliveryFee), tr.courierid, res.email
        INTO biaya_pengantaran, total_harga_makanan, id_kurir, email_restoran
        FROM transaction tr
        JOIN transaction_history th on tr.email = th.email
        JOIN transaction_status ts on ts.id = th.tsid
        JOIN transaction_food tf on tf.email = tr.email and tf.datetime = tr.datetime
        JOIN food f on f.rname = tf.rname and f.rbranch = tf.rbranch and f.foodname = tf.foodname
        JOIN restaurant res on res.rname = f.rname and res.rbranch = f.rbranch;

        UPDATE transaction_actor set restopay = restopay + biaya_pengantaran
        WHERE email = id_kurir;

        UPDATE transaction_actor set restopay = restopay + total_harga_makanan
        WHERE email = email_restoran;
    END IF;
    RETURN new;
END;
$$;


ALTER FUNCTION sirest.menambah_restopay() OWNER TO db22a003;

--
-- Name: pendaftaran(); Type: FUNCTION; Schema: sirest; Owner: db22a003
--

CREATE FUNCTION sirest.pendaftaran() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 IF regexp_count(NEW.password, '[0-9]+') > 0 AND regexp_count(NEW.password, '[A-Z]+') > 0 THEN
     RETURN NEW;
 ELSE
     RAISE EXCEPTION 'Password harus memiliki minimal 1 huruf kapital dan 1 angka!';
 END IF;
END;
$$;


ALTER FUNCTION sirest.pendaftaran() OWNER TO db22a003;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.admin (
    email character varying(50) NOT NULL
);


ALTER TABLE sirest.admin OWNER TO db22a003;

--
-- Name: courier; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.courier (
    email character varying(50) NOT NULL,
    platenum character varying(10) NOT NULL,
    drivinglicensenum character varying(20) NOT NULL,
    vehicletype character varying(15) NOT NULL,
    vehiclebrand character varying(15) NOT NULL
);


ALTER TABLE sirest.courier OWNER TO db22a003;

--
-- Name: customer; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.customer (
    email character varying(50) NOT NULL,
    birthdate date NOT NULL,
    sex character(1) NOT NULL
);


ALTER TABLE sirest.customer OWNER TO db22a003;

--
-- Name: delivery_fee_per_km; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.delivery_fee_per_km (
    id character varying(20) NOT NULL,
    province character varying(25) NOT NULL,
    motorfee integer NOT NULL,
    carfee integer NOT NULL
);


ALTER TABLE sirest.delivery_fee_per_km OWNER TO db22a003;

--
-- Name: food; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.food (
    rname character varying(25) NOT NULL,
    rbranch character varying(25) NOT NULL,
    foodname character varying(50) NOT NULL,
    description text,
    stock integer NOT NULL,
    price bigint NOT NULL,
    fcategory character varying(20) NOT NULL
);


ALTER TABLE sirest.food OWNER TO db22a003;

--
-- Name: food_category; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.food_category (
    id character varying(20) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE sirest.food_category OWNER TO db22a003;

--
-- Name: food_ingredient; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.food_ingredient (
    rname character varying(25) NOT NULL,
    rbranch character varying(25) NOT NULL,
    foodname character varying(50) NOT NULL,
    ingredient character varying(25) NOT NULL
);


ALTER TABLE sirest.food_ingredient OWNER TO db22a003;

--
-- Name: ingredient; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.ingredient (
    id character varying(25) NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE sirest.ingredient OWNER TO db22a003;

--
-- Name: min_transaction_promo; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.min_transaction_promo (
    id character varying(25) NOT NULL,
    minimumtransactionnum integer NOT NULL
);


ALTER TABLE sirest.min_transaction_promo OWNER TO db22a003;

--
-- Name: payment_method; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.payment_method (
    id character varying(25) NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE sirest.payment_method OWNER TO db22a003;

--
-- Name: payment_status; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.payment_status (
    id character varying(25) NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE sirest.payment_status OWNER TO db22a003;

--
-- Name: promo; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.promo (
    id character varying(25) NOT NULL,
    promoname character varying(25) NOT NULL,
    discount integer,
    CONSTRAINT promo_discount_check CHECK (((discount >= 1) AND (discount <= 100)))
);


ALTER TABLE sirest.promo OWNER TO db22a003;

--
-- Name: restaurant; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.restaurant (
    rname character varying(25) NOT NULL,
    rbranch character varying(25) NOT NULL,
    email character varying(50),
    rphonenum character varying(18) NOT NULL,
    street character varying(30) NOT NULL,
    district character varying(20) NOT NULL,
    city character varying(20) NOT NULL,
    province character varying(20) NOT NULL,
    rating integer DEFAULT 0 NOT NULL,
    rcategory character varying(20),
    CONSTRAINT restaurant_rating_check CHECK (((rating >= 0) AND (rating <= 10)))
);


ALTER TABLE sirest.restaurant OWNER TO db22a003;

--
-- Name: restaurant_category; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.restaurant_category (
    id character varying(20) NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE sirest.restaurant_category OWNER TO db22a003;

--
-- Name: restaurant_operating_hours; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.restaurant_operating_hours (
    name character varying(25) NOT NULL,
    branch character varying(25) NOT NULL,
    day character varying(10) NOT NULL,
    starthours time without time zone NOT NULL,
    endhours time without time zone NOT NULL
);


ALTER TABLE sirest.restaurant_operating_hours OWNER TO db22a003;

--
-- Name: restaurant_promo; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.restaurant_promo (
    rname character varying(25) NOT NULL,
    rbranch character varying(25) NOT NULL,
    pid character varying(25) NOT NULL,
    rpromo_start timestamp without time zone NOT NULL,
    rpromo_end timestamp without time zone NOT NULL
);


ALTER TABLE sirest.restaurant_promo OWNER TO db22a003;

--
-- Name: special_day_promo; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.special_day_promo (
    id character varying(25) NOT NULL,
    date timestamp without time zone NOT NULL
);


ALTER TABLE sirest.special_day_promo OWNER TO db22a003;

--
-- Name: transaction; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.transaction (
    email character varying(50) NOT NULL,
    datetime timestamp without time zone NOT NULL,
    street character varying(30) NOT NULL,
    district character varying(30) NOT NULL,
    city character varying(25) NOT NULL,
    province character varying(25) NOT NULL,
    totalfood double precision NOT NULL,
    totaldiscount double precision NOT NULL,
    deliveryfee double precision NOT NULL,
    totalprice double precision NOT NULL,
    rating integer,
    pmid character varying(25) NOT NULL,
    psid character varying(25) NOT NULL,
    dfid character varying(20) NOT NULL,
    courierid character varying(50),
    vehicletype character varying(15) NOT NULL
);


ALTER TABLE sirest.transaction OWNER TO db22a003;

--
-- Name: transaction_actor; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.transaction_actor (
    email character varying(50) NOT NULL,
    nik character varying(20) NOT NULL,
    bankname character varying(20) NOT NULL,
    accountno character varying(20) NOT NULL,
    restopay bigint DEFAULT 0 NOT NULL,
    adminid character varying(50)
);


ALTER TABLE sirest.transaction_actor OWNER TO db22a003;

--
-- Name: transaction_food; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.transaction_food (
    email character varying(50) NOT NULL,
    datetime timestamp without time zone NOT NULL,
    rname character varying(50) NOT NULL,
    rbranch character varying(25) NOT NULL,
    foodname character varying(50) NOT NULL,
    amount integer NOT NULL,
    note character varying(255)
);


ALTER TABLE sirest.transaction_food OWNER TO db22a003;

--
-- Name: transaction_history; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.transaction_history (
    email character varying(50) NOT NULL,
    datetime timestamp without time zone NOT NULL,
    tsid character varying(25) NOT NULL,
    datetimestatus character varying(20) NOT NULL
);


ALTER TABLE sirest.transaction_history OWNER TO db22a003;

--
-- Name: transaction_status; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.transaction_status (
    id character varying(25) NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE sirest.transaction_status OWNER TO db22a003;

--
-- Name: user_acc; Type: TABLE; Schema: sirest; Owner: db22a003
--

CREATE TABLE sirest.user_acc (
    email character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    phonenum character varying(20) NOT NULL,
    fname character varying(15) NOT NULL,
    lname character varying(15) NOT NULL
);


ALTER TABLE sirest.user_acc OWNER TO db22a003;

--
-- Data for Name: admin; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.admin (email) FROM stdin;
mthompsett0@wunderground.com
istirzaker1@tripod.com
ahamshaw2@wordpress.org
tjacobsz3@dyndns.org
jcasiero4@unblog.fr
\.


--
-- Data for Name: courier; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.courier (email, platenum, drivinglicensenum, vehicletype, vehiclebrand) FROM stdin;
anornable5@amazon.co.jp QF1996RKC       pzhKLxebQA      Motor   Atoyot
nlynthal6@techcrunch.com        XX4820UEW       BhGednrgFE      Motor   Wumbo
ringlis7@sohu.com       CD2170AQH       nQShPWKjMs      Motor   Atoyot
gbuckthorp8@forbes.com  QS1654YSL       BAEXJYItZv      Motor   Dohan
lgrgic9@ftc.gov EI2250BCT       VyoAiyJTlt      Motor   Wumbo
ctoppina@blogs.com      KF9128AXX       MmiJhTkAP       Car     Dohan
gbalfourb@vinaora.com   PT2530PKW       cJskgahJLa      Car     Dohan
bmaytomc@quantcast.com  BA1928SDA       IkNaTsMkn       Car     Atoyot
pdewfalld@topsy.com     MP7112PII       AmOguSSus       Car     Arferia
kcapine@senate.gov      AM1059GUS       taKznsaBaFh     Car     Arferia
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.customer (email, birthdate, sex) FROM stdin;
isimonetonf@about.com   1991-09-02      F
gburfordg@chron.com     1996-05-03      M
wrawsthorneh@loc.gov    1989-10-02      F
sklugmani@reference.com 1997-09-03      M
lcattellj@bing.com      1999-08-06      F
etantk@deviantart.com   1987-04-02      F
gtunnacliffel@gmpg.org  1981-08-10      M
gspiniellom@dot.gov     1989-08-21      M
dguiraudn@jiathis.com   1981-11-25      M
criddiougho@google.ru   1980-07-13      F
ablunsump@time.com      1996-11-27      M
hmayhouq@google.de      1989-05-23      F
rbleacherr@baidu.com    1995-11-05      F
dstruthers@jiathis.com  1990-07-21      M
doadet@sourceforge.net  1987-12-14      M
mbolsoveru@i2i.jp       1986-04-28      M
dchillingsworthv@wikia.com      1984-02-06      F
bpatemorew@opera.com    1989-02-05      M
mdeasonx@furl.net       1984-06-17      M
tpiffordy@lycos.com     1980-12-26      M
\.


--
-- Data for Name: delivery_fee_per_km; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.delivery_fee_per_km (id, province, motorfee, carfee) FROM stdin;
D1      West Java       10000   15000
D2      East Java       20000   25000
D3      West Sulawesi   11000   16000
D4      North Java      12000   17000
D5      South Java      15000   20000
D6      East Sulawesi   10000   14000
D7      North Sumatera  12000   16000
D8      South Sumatera  9000    14000
D9      Central Java    10000   15000
D10     East Kalimantan 8000    13000
\.


--
-- Data for Name: food; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.food (rname, rbranch, foodname, description, stock, price, fcategory) FROM stdin;
Sunda Food      Sutteridge      Milk    Milk is our everyday product    40      5000    FC1
Sunda Food      Paget Terrace   Bread   Bread is a staple food made out of Flour, water, and yeast.     60      5500    FC3
Burger Queen    Eagle   Fried Rice      Fried rice is a really good food        90      24000   FC4
Venti's Dandelion       Cheese  Cheese is a product of milk.    100     3000    FC5
Pizza Hat       Derek Crossing  Rendang Rendang is a spicy and delicious food   120     20000   FC4
Kaswel  Gale    Sandwich        Sandwich is the most common breakfast, any dish, where the bread serves as a wrapper for other food items.      30      10000       FC2
Chickenies      Almo Drive      Pancake A pancake is a flat cake cooked on a hot surface such as a frying pan.  40      12500   FC5
Rice-To Linden Court    Pie     A Pie is a baked dish of fruits or even vegetables, with its top and base of a pastry.  23      13000   FC2
Golden Star     Krajan  Steak   Steak is a meat filled with riches      47      30000   FC4
Foresta Matumadua       Pizza   Pizza is our most favorite Fast food. We can buy Pizza or maybe even make it at home.   31      49000   FC3
Sunda Food      Sutteridge      Donuts  A doughnut or donut is a popular sweet dish, which is a leavened fried dough.   21      40000   FC5
Sunda Food      Paget Terrace   Salad   Salad is a cold dish that contains a mixture of raw and cooked vegetables, typically seasoned with different salts, oil, vinegar, or some other dressing.   15      10000   FC2
Burger Queen    Eagle   Meatball        Meatballs are ground meat rolled into tiny balls which are cooked in a different sauce. 170     15000   FC4
Venti's Dandelion       GrilledChicken  Grilled chicken consists of parts of chicken or the whole chicken Grilled and cooked.   45      23000   FC4
Pizza Hat       Derek Crossing  Hamburger       A Hamburger is also considered a sandwich that has more than one patty. 55      25000   FC4
Kaswel  Gale    Tuna    Tuna is a saltwater fish.       68      17000   FC4
Chickenies      Almo Drive      Noodles Noodles are made from leavened dough, which is roles and stretched and cut into thin strips.    73      12000   FC4
Rice-To Linden Court    Egg     We all know what an Egg is. They are laid by the female animals of different animals, for example, birds, reptiles, and amphibians. 12      3000    FC2
Golden Star     Krajan  Bacon   Bacon is salted pork made from the pork belly or the lesser fat region of the back cuts.        98      34000   FC4
Foresta Matumadua       Waffle  Waffles are made from leavened dough, and it is cooked between two plates, giving them a specific surface pattern, size, and shape. 110     17000   FC3
Sunda Food      Sutteridge      FrenchFries     French Fries is a French dish, originated in Belgium, which is Potatoes deep-fried.     23      16000   FC4
Sunda Food      Paget Terrace   Biryani Biryani is the most popular Indian dish. It contains highly seasoned rice with meat, and sometimes veggies and eggs too.    43      30000   FC4
Burger Queen    Eagle   Pasta   Pasta is also a dish made from leavened dough mixed with eggs formed in different shapes and sizes.     77      17000   FC5
Venti's Dandelion       SmokedSalmon    Salmon is the common name for ray-finned fish in the family Salmonidae. 99      45000   FC4
Pizza Hat       Derek Crossing  Mayonnaise      Mayonnaise, or informally called Mayo, is a thick cold sauce usually used for Salads or fries.  100     600FC5
Kaswel  Gale    Taco    Taco is a traditional Mexican dish. It contains small tortillas with filling.   125     18000   FC3
Chickenies      Almo Drive      Hotdog  The hot dog is another famous Fast food, which is grilled it steamed Sausage placed in between sliced bread.    32 12000    FC3
Rice-To Linden Court    Dosa    Dosa is a South Indian dish. It is similar to a crepe in appearance, although a Dosa emphasizes the Savory flavor more. 10 30400    FC1
Golden Star     Krajan  Chocolate       Chocolate is made from roasted ground cacao pods.       5       12000   FC3
Foresta Matumadua       IceCream        It is a frozen dessert that is usually taken as a snack or dessert.     400     59000   FC1
\.


--
-- Data for Name: food_category; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.food_category (id, name) FROM stdin;
FC1     Minuman
FC2     Sayuran
FC3     Entree
FC4     Makanan
FC5     Hidangan Penutup
\.


--
-- Data for Name: food_ingredient; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.food_ingredient (rname, rbranch, foodname, ingredient) FROM stdin;
Sunda Food      Sutteridge      Milk    I5
Sunda Food      Paget Terrace   Bread   I19
Burger Queen    Eagle   Fried Rice      I18
Venti's Dandelion       Cheese  I10
Pizza Hat       Derek Crossing  Rendang I15
Kaswel  Gale    Sandwich        I3
Chickenies      Almo Drive      Pancake I20
Rice-To Linden Court    Pie     I11
Golden Star     Krajan  Steak   I20
Foresta Matumadua       Pizza   I13
Sunda Food      Sutteridge      Donuts  I19
Sunda Food      Paget Terrace   Salad   I20
Burger Queen    Eagle   Meatball        I4
Venti's Dandelion       GrilledChicken  I17
Pizza Hat       Derek Crossing  Hamburger       I17
Kaswel  Gale    Tuna    I12
Chickenies      Almo Drive      Noodles I13
Rice-To Linden Court    Egg     I20
Golden Star     Krajan  Bacon   I2
Foresta Matumadua       Waffle  I11
Sunda Food      Sutteridge      FrenchFries     I18
Sunda Food      Paget Terrace   Biryani I6
Burger Queen    Eagle   Pasta   I7
Venti's Dandelion       SmokedSalmon    I2
Pizza Hat       Derek Crossing  Mayonnaise      I18
Kaswel  Gale    Taco    I15
Chickenies      Almo Drive      Hotdog  I6
Rice-To Linden Court    Dosa    I15
Golden Star     Krajan  Chocolate       I7
Foresta Matumadua       IceCream        I6
\.


--
-- Data for Name: ingredient; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.ingredient (id, name) FROM stdin;
I1      Sayuran
I2      Bumbu
I3      Rempah
I4      Cereal
I5      Kacang-kacangan
I6      Daging ayam
I7      Daging sapi
I8      Susu
I9      Buah-buahan
I10     Ikan
I11     Gula
I12     Garam
I13     Minyak
I14     Telur
I15     Margarin
I16     Kecap
I17     Mentega
I18     Tepung
I19     Air
I20     Jahe
\.


--
-- Data for Name: min_transaction_promo; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.min_transaction_promo (id, minimumtransactionnum) FROM stdin;
MTP1    50000
MTP2    25000
MTP3    20000
MTP4    20000
MTP5    25000
MTP6    50000
MTP7    25000
MTP8    77777
MTP9    75000
MTP10   100000
\.


--
-- Data for Name: payment_method; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.payment_method (id, name) FROM stdin;
PM1     ATM
PM2     m-banking
PM3     Indomaret/Alfamart
PM4     RestoPay
PM5     e-wallet
\.


--
-- Data for Name: payment_status; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.payment_status (id, name) FROM stdin;
PS1     Menunggu Pembayaran
PS2     Berhasil
PS3     Gagal
\.


--
-- Data for Name: promo; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.promo (id, promoname, discount) FROM stdin;
SDP1    Tahun Baru      30
SDP2    CNY     10
SDP3    Hari Pancasila  5
SDP4    Idul Fitri      25
SDP5    Idul Adha       15
SDP6    Natal   25
SDP7    HUT RI  17
SDP8    Maulid  10
SDP9    Waisak  10
SDP10   Hari Kartini    5
MTP1    YUK50   20
MTP2    YUK25   10
MTP3    YUK20   5
MTP4    GAS20   5
MTP5    GAS25   10
MTP6    GAS50   20
MTP7    NGENG25 10
MTP8    NGENG50 20
MTP9    FS75    30
MTP10   FS100   50
\.


--
-- Data for Name: restaurant; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.restaurant (rname, rbranch, email, rphonenum, street, district, city, province, rating, rcategory) FROM stdin;
Sunda Food      Sutteridge      mbauchopz@ehow.com      5891605325.0    526 Sutteridge Trail    Rose    Shuishi West Java       8       RC1
Sunda Food      Paget Terrace   lstquentin10@multiply.com       4586326330.0    67 Paget Terrace        Buffalo San Francisco   East Java       7       RC1
Burger Queen    Eagle   mpatriskson11@cam.ac.uk 4377546129.0    5633 5th Road   Eagle   Merdeka West Sulawesi   1       RC2
Venti's Dandelion       jennor12@xrea.com       7228511534.0    0632 Onsgard Terrace    Dandelion       Rosh Pinna      North Java      6       RC2
Pizza Hat       Derek Crossing  ocowie13@blinklist.com  5298549290.0    262 Derek Crossing      Okeanos Nevytsake       South Java      9       RC2
Kaswel  Gale    bdubois14@answers.com   6654518782.0    5234 Homewood Avenue    Gale    Aettal  East Sulawesi   8       RC3
Chickenies      Almo Drive      smatijasevic15@house.gov        6261606265.0    626 Almo Drive  Flora   Wangpu  North Sumatera  6       RC3
Rice-To Linden Court    smagarrell16@webmd.com  4168941148.0    74 Linden Court Rose    Haarlem South Sumatera  9       RC4
Golden Star     Krajan  ttavinor17@google.es    2448286375.0    2 Northland Crossing    Buffalo Krajan  Central Java    7       RC5
Foresta Matumadua       amottershead18@baidu.com        2597328863.0    61 Utah Way     Eagle   Matumadua       East Kalimantan 7       RC5
\.


--
-- Data for Name: restaurant_category; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.restaurant_category (id, name) FROM stdin;
RC1     Ethnic
RC2     Fast Food
RC3     Casual Dining
RC4     Family Style
RC5     Fine Dining
\.


--
-- Data for Name: restaurant_operating_hours; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.restaurant_operating_hours (name, branch, day, starthours, endhours) FROM stdin;
Sunda Food      Sutteridge      Rabu    08:00:00        16:01:00
Sunda Food      Paget Terrace   Kamis   08:05:00        16:04:00
Burger Queen    Eagle   Minggu  08:09:00        16:05:00
Venti's Dandelion       Kamis   08:19:00        16:06:00
Pizza Hat       Derek Crossing  Jumat   08:20:00        16:07:00
Kaswel  Gale    Jumat   08:22:00        16:11:00
Chickenies      Almo Drive      Sabtu   08:26:00        16:13:00
Rice-To Linden Court    Minggu  08:27:00        16:17:00
Golden Star     Krajan  Kamis   08:28:00        16:19:00
Foresta Matumadua       Jumat   08:29:00        16:21:00
Sunda Food      Sutteridge      Selasa  08:30:00        16:23:00
Sunda Food      Paget Terrace   Rabu    08:36:00        16:32:00
Burger Queen    Eagle   Jumat   08:37:00        16:35:00
Venti's Dandelion       Senin   08:40:00        16:39:00
Pizza Hat       Derek Crossing  Kamis   08:41:00        16:41:00
Kaswel  Gale    Senin   08:49:00        16:42:00
Chickenies      Almo Drive      Minggu  08:50:00        16:45:00
Rice-To Linden Court    Senin   08:57:00        16:47:00
Golden Star     Krajan  Sabtu   08:58:00        16:53:00
Foresta Matumadua       Minggu  08:59:00        16:54:00
Sunda Food      Sutteridge      Senin   09:00:00        16:59:00
Sunda Food      Paget Terrace   Jumat   09:08:00        17:03:00
Burger Queen    Eagle   Rabu    09:09:00        17:08:00
Venti's Dandelion       Minggu  09:10:00        17:13:00
Pizza Hat       Derek Crossing  Rabu    09:11:00        17:14:00
Kaswel  Gale    Selasa  09:12:00        17:20:00
Chickenies      Almo Drive      Jumat   09:14:00        17:21:00
Rice-To Linden Court    Kamis   09:16:00        17:23:00
Golden Star     Krajan  Jumat   09:19:00        17:24:00
Foresta Matumadua       Senin   09:28:00        17:26:00
\.


--
-- Data for Name: restaurant_promo; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.restaurant_promo (rname, rbranch, pid, rpromo_start, rpromo_end) FROM stdin;
Kaswel  Gale    MTP10   2022-02-19 00:00:00     2022-03-29 12:00:00
Golden Star     Krajan  MTP9    2020-01-05 00:00:00     2020-01-07 12:00:00
Sunda Food      Sutteridge      MTP2    2021-07-08 00:00:00     2021-08-08 12:00:00
Rice-To Linden Court    MTP5    2021-07-10 00:00:00     2021-07-15 12:00:00
Foresta Matumadua       MTP4    2020-05-17 00:00:00     2020-05-20 12:00:00
Burger Queen    Eagle   MTP6    2022-08-14 00:00:00     2022-08-18 12:00:00
Rice-To Linden Court    MTP8    2022-10-05 00:00:00     2022-10-08 12:00:00
Golden Star     Krajan  MTP3    2021-12-17 00:00:00     2021-12-25 12:00:00
Venti's Dandelion       MTP7    2020-06-18 00:00:00     2020-06-25 12:00:00
Kaswel  Gale    MTP1    2020-06-26 00:00:00     2020-07-05 12:00:00
\.


--
-- Data for Name: special_day_promo; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.special_day_promo (id, date) FROM stdin;
SDP1    2023-01-01 00:00:00
SDP2    2023-01-22 00:00:00
SDP3    2023-06-01 00:00:00
SDP4    2023-04-22 00:00:00
SDP5    2023-06-28 00:00:00
SDP6    2023-12-25 00:00:00
SDP7    2023-08-17 00:00:00
SDP8    2023-09-26 00:00:00
SDP9    2023-05-05 00:00:00
SDP10   2023-04-21 00:00:00
\.


--
-- Data for Name: transaction; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.transaction (email, datetime, street, district, city, province, totalfood, totaldiscount, deliveryfee, totalprice, rating, pmid, psid, dfid, courierid, vehicletype) FROM stdin;
dguiraudn@jiathis.com   2022-08-15 09:23:03     5633 5th Road   Eagle   Merdeka West Sulawesi   2       0       11000   59000   4       PM1     PS2     D3 ringlis7@sohu.com        Motor
criddiougho@google.ru   2022-09-12 15:05:20     0632 Onsgard Terrace    Dandelion       Rosh Pinna      North Java      1       0       12000   35000   5  PM3      PS2     D4      gbuckthorp8@forbes.com  Motor
sklugmani@reference.com 2020-05-19 13:25:54     61 Utah Way     Eagle   Matumadua       East Kalimantan 4       9800    8000    194200  5       PM1     PS3D10      gbuckthorp8@forbes.com  Motor
sklugmani@reference.com 2022-09-13 13:21:45     262 Derek Crossing      Okeanos Nevytsake       South Java      3       0       15000   90000   5       PM3PS2      D5      lgrgic9@ftc.gov Motor
lcattellj@bing.com      2022-05-23 13:43:29     526 Sutteridge Trail    Rose    Shuishi West Java       14      0       15000   295000  5       PM5     PS2D1       lgrgic9@ftc.gov Motor
etantk@deviantart.com   2020-06-28 15:14:22     5234 Homewood Avenue    Gale    Aettal  East Sulawesi   3       0       10000   40000   5       PM5     PS2D6       ctoppina@blogs.com      Car
rbleacherr@baidu.com    2022-03-23 09:48:25     626 Almo Drive  Flora   Wangpu  North Sumatera  2       0       16000   41000   3       PM1     PS2     D7 gbalfourb@vinaora.com    Car
wrawsthorneh@loc.gov    2021-12-21 13:21:43     2 Northland Crossing    Buffalo Krajan  Central Java    2       3000    15000   72000   4       PM5     PS3D9       gbalfourb@vinaora.com   Car
gburfordg@chron.com     2022-10-06 11:12:17     74 Linden Court Rose    Haarlem South Sumatera  5       0       14000   79000   1       PM5     PS2     D8 bmaytomc@quantcast.com   Car
etantk@deviantart.com   2021-07-15 14:34:21     74 Linden Court Rose    Haarlem South Sumatera  1       0       20000   23000   4       PM2     PS1     D8 bmaytomc@quantcast.com   Car
\.


--
-- Data for Name: transaction_actor; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.transaction_actor (email, nik, bankname, accountno, restopay, adminid) FROM stdin;
anornable5@amazon.co.jp 9690036925.0    Mandaria Bank   2409213596.0    927000  mthompsett0@wunderground.com
nlynthal6@techcrunch.com        8288465111.0    Mandaria Bank   7521274299.0    30000   istirzaker1@tripod.com
ringlis7@sohu.com       1385479781.0    Mandaria Bank   5283042452.0    807000  mthompsett0@wunderground.com
gbuckthorp8@forbes.com  6259226419.0    Mandaria Bank   3405788620.0    558000  ahamshaw2@wordpress.org
lgrgic9@ftc.gov 8723579933.0    Mandaria Bank   7402181375.0    198000  istirzaker1@tripod.com
ctoppina@blogs.com      7873130080.0    Mandaria Bank   5591357585.0    239000  tjacobsz3@dyndns.org
gbalfourb@vinaora.com   8219394981.0    Mandaria Bank   5681663542.0    151000  mthompsett0@wunderground.com
bmaytomc@quantcast.com  4942174013.0    Mandaria Bank   6775813789.0    66000   jcasiero4@unblog.fr
pdewfalld@topsy.com     6935403556.0    Mandaria Bank   2914808728.0    536000  mthompsett0@wunderground.com
kcapine@senate.gov      7186237714.0    Mandaria Bank   3474763568.0    405000  ahamshaw2@wordpress.org
isimonetonf@about.com   4942475460.0    Mandaria Bank   2115996829.0    842000  ahamshaw2@wordpress.org
gburfordg@chron.com     8828820949.0    Mandaria Bank   5380751289.0    353000  istirzaker1@tripod.com
wrawsthorneh@loc.gov    3401694924.0    Mandaria Bank   2190823836.0    823000  tjacobsz3@dyndns.org
sklugmani@reference.com 6369942316.0    Mandaria Bank   9430224451.0    837000  mthompsett0@wunderground.com
lcattellj@bing.com      7755202533.0    Mandaria Bank   6561217405.0    308000  mthompsett0@wunderground.com
etantk@deviantart.com   8234448343.0    Mandaria Bank   6494456810.0    849000  tjacobsz3@dyndns.org
gtunnacliffel@gmpg.org  9501665933.0    Beeny Bank      2007748971.0    676000  ahamshaw2@wordpress.org
gspiniellom@dot.gov     7116323367.0    Beeny Bank      3649039526.0    158000  istirzaker1@tripod.com
dguiraudn@jiathis.com   3020406551.0    Beeny Bank      1888753505.0    901000  istirzaker1@tripod.com
criddiougho@google.ru   2352661287.0    Beeny Bank      2006164522.0    842000  mthompsett0@wunderground.com
ablunsump@time.com      8147362644.0    Beeny Bank      5521242581.0    177000  ahamshaw2@wordpress.org
hmayhouq@google.de      8570528751.0    Beeny Bank      7513210452.0    428000  tjacobsz3@dyndns.org
rbleacherr@baidu.com    2188611528.0    Beeny Bank      7154516971.0    496000  mthompsett0@wunderground.com
dstruthers@jiathis.com  6978841692.0    Beeny Bank      9031256856.0    969000  tjacobsz3@dyndns.org
doadet@sourceforge.net  3680951359.0    Beeny Bank      7511618079.0    187000  istirzaker1@tripod.com
mbolsoveru@i2i.jp       7098199920.0    Beeny Bank      7690908668.0    943000  ahamshaw2@wordpress.org
dchillingsworthv@wikia.com      8223128980.0    Beeny Bank      3546616170.0    325000  mthompsett0@wunderground.com
bpatemorew@opera.com    6318043672.0    Beeny Bank      1241575774.0    489000  tjacobsz3@dyndns.org
mdeasonx@furl.net       9663196808.0    Beeny Bank      3553766633.0    464000  mthompsett0@wunderground.com
tpiffordy@lycos.com     1790289783.0    Beeny Bank      7332499122.0    941000  ahamshaw2@wordpress.org
mbauchopz@ehow.com      6914466444.0    Beeny Bank      3823617944.0    386000  tjacobsz3@dyndns.org
lstquentin10@multiply.com       2557621614.0    Beeny Bank      8655214688.0    230000  istirzaker1@tripod.com
mpatriskson11@cam.ac.uk 4344226326.0    Beeny Bank      3136154934.0    53000   istirzaker1@tripod.com
jennor12@xrea.com       9715473969.0    Beeny Bank      1384731701.0    371000  jcasiero4@unblog.fr
ocowie13@blinklist.com  7659418673.0    Beeny Bank      2744904669.0    64000   mthompsett0@wunderground.com
bdubois14@answers.com   5002930055.0    Beeny Bank      5420656263.0    112000  ahamshaw2@wordpress.org
smatijasevic15@house.gov        7028489428.0    Beeny Bank      1661617676.0    582000  ahamshaw2@wordpress.org
smagarrell16@webmd.com  7699468674.0    Blue Sea Bank   7054144604.0    246000  jcasiero4@unblog.fr
ttavinor17@google.es    6161995500.0    Blue Sea Bank   2724652416.0    470000  istirzaker1@tripod.com
amottershead18@baidu.com        7058844626.0    Blue Sea Bank   7272630293.0    407000  mthompsett0@wunderground.com
\.


--
-- Data for Name: transaction_food; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.transaction_food (email, datetime, rname, rbranch, foodname, amount, note) FROM stdin;
gburfordg@chron.com     2022-10-06 11:12:17     Rice-To Linden Court    Pie     5       \N
wrawsthorneh@loc.gov    2021-12-21 13:21:43     Golden Star     Krajan  Steak   2       saus dipisah
sklugmani@reference.com 2020-05-19 13:25:54     Foresta Matumadua       Pizza   4       \N
lcattellj@bing.com      2022-05-23 13:43:29     Sunda Food      Sutteridge      Milk    8       dengan sedotan
lcattellj@bing.com      2022-05-23 13:43:29     Sunda Food      Sutteridge      Donuts  6       \N
dguiraudn@jiathis.com   2022-08-15 09:23:03     Burger Queen    Eagle   Fried Rice      2       pedas
criddiougho@google.ru   2022-09-12 15:05:20     Venti's Dandelion       GrilledChicken  1       tidak pedas
sklugmani@reference.com 2022-09-13 13:21:45     Pizza Hat       Derek Crossing  Hamburger       3       tanpa selada
etantk@deviantart.com   2020-06-28 15:14:22     Kaswel  Gale    Sandwich        3       \N
rbleacherr@baidu.com    2022-03-23 09:48:25     Chickenies      Almo Drive      Pancake 2       \N
etantk@deviantart.com   2021-07-15 14:34:21     Rice-To Linden Court    Egg     1       \N
\.


--
-- Data for Name: transaction_history; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.transaction_history (email, datetime, tsid, datetimestatus) FROM stdin;
dguiraudn@jiathis.com   2022-08-15 09:23:03     TS4     2022-08-15 09:53:03
criddiougho@google.ru   2022-09-12 15:05:20     TS4     2022-09-12 15:45:20
sklugmani@reference.com 2022-09-13 13:21:45     TS4     2022-09-13 13:47:45
etantk@deviantart.com   2020-06-28 15:14:22     TS4     2020-06-28 15:59:42
rbleacherr@baidu.com    2022-03-23 09:48:25     TS4     2022-03-23 10:03:25
gburfordg@chron.com     2022-10-06 11:12:17     TS4     2022-10-06 11:59:17
wrawsthorneh@loc.gov    2021-12-21 13:21:43     TS5     2021-12-21 13:51:43
sklugmani@reference.com 2020-05-19 13:25:54     TS5     2020-05-19 14:00:54
lcattellj@bing.com      2022-05-23 13:43:29     TS3     2022-05-23 13:49:29
etantk@deviantart.com   2021-07-15 14:34:21     TS1     2021-07-15 14:36:21
\.


--
-- Data for Name: transaction_status; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.transaction_status (id, name) FROM stdin;
TS1     Menunggu Konfirmasi Resto
TS2     Pesanan Dibuat
TS3     Pesanan Diantar
TS4     Pesanan Selesai
TS5     Pesanan Dibatalkan
\.


--
-- Data for Name: user_acc; Type: TABLE DATA; Schema: sirest; Owner: db22a003
--

COPY sirest.user_acc (email, password, phonenum, fname, lname) FROM stdin;
mthompsett0@wunderground.com    hsIdpITTH0t     7171399292.0    Marne   Thompsett
istirzaker1@tripod.com  rzxf9nhlNHUY    7532559923.0    Ilka    Stirzaker
ahamshaw2@wordpress.org cElio45uI7H     6912066383.0    Ardyth  Hamshaw
tjacobsz3@dyndns.org    gLcHM0TzW       7864471621.0    Tracey  Jacobsz
jcasiero4@unblog.fr     O9EXIvLSyFd6    7285663638.0    Jolyn   Casiero
anornable5@amazon.co.jp zXsIHs1KHyz     7596862910.0    Alfi    Nornable
nlynthal6@techcrunch.com        5B0RHbTkle0     4301443702.0    Nicky   Lynthal
ringlis7@sohu.com       Lxg5ImuacSi     4329293947.0    Roger   Inglis
gbuckthorp8@forbes.com  7WWchTgM9I      8568341777.0    Gibbie  Buckthorp
lgrgic9@ftc.gov kGJqKAxwv       9592789461.0    Loretta Grgic
ctoppina@blogs.com      UnwCr6e 4511644355.0    Clyde   Toppin
gbalfourb@vinaora.com   y32AtyLVavH     4824095922.0    Gareth  Balfour
bmaytomc@quantcast.com  qtF5tQciZ       4135518850.0    Bernette        Maytom
pdewfalld@topsy.com     7nnW069mJUMz    3225951080.0    Pennie  Dewfall
kcapine@senate.gov      fG1pnqnaRq      6415839817.0    Karlens Capin
isimonetonf@about.com   IW03vzc 6131577963.0    Ignacius        Simoneton
gburfordg@chron.com     pvOCWseIL       6413216400.0    Gussi   Burford
wrawsthorneh@loc.gov    9Y4fuL  7329690880.0    Worth   Rawsthorne
sklugmani@reference.com FNgMx5wvm       2225650045.0    Selestina       Klugman
lcattellj@bing.com      hTF7X5BsWmcy    5546168060.0    Lyndsie Cattell
etantk@deviantart.com   7IKN1r  4444342948.0    Erin    Tant
gtunnacliffel@gmpg.org  6tXDIb4Px       7821101935.0    Gaspard Tunnacliffe
gspiniellom@dot.gov     6llv6ieH9r      1015966976.0    Glenn   Spiniello
dguiraudn@jiathis.com   deD5Icz 7785243541.0    Dulcine Guiraud
criddiougho@google.ru   WwVkUCOd        9411842747.0    Catarina        Riddiough
ablunsump@time.com      UfKPkO42        5354145405.0    Alaric  Blunsum
hmayhouq@google.de      9CvVAQ  6212654233.0    Hally   Mayhou
rbleacherr@baidu.com    c0WRQoVB        4113785526.0    Ryley   Bleacher
dstruthers@jiathis.com  b4XRvxAb        8568210310.0    Danny   Struther
doadet@sourceforge.net  bMca3W  8365480942.0    Donnie  Oade
mbolsoveru@i2i.jp       9urkcfxkBrI     2245671450.0    Matthaeus       Bolsover
dchillingsworthv@wikia.com      uudLFo  7614571594.0    Darnell Chillingsworth
bpatemorew@opera.com    te2VUOLpg       5479928342.0    Barny   Patemore
mdeasonx@furl.net       XdNbP469i       5282148787.0    Merrili Deason
tpiffordy@lycos.com     AgcbvfjcJWfd    6834236959.0    Tamera  Pifford
mbauchopz@ehow.com      SHbqbTan        6232683521.0    Marcia  Bauchop
lstquentin10@multiply.com       tJB0szHz2       7652267658.0    Letty   St. Quentin
mpatriskson11@cam.ac.uk uIzdWL3k        4466576255.0    Marlie  Patriskson
jennor12@xrea.com       rdBC3lgyM       6904176522.0    Judah   Ennor
ocowie13@blinklist.com  wRLqEnd 4011028994.0    Odo     Cowie
bdubois14@answers.com   v0DtIGxXYdFh    5886554668.0    Bryant  Dubois
smatijasevic15@house.gov        gWLeQ0B6        4885284504.0    Steward Matijasevic
smagarrell16@webmd.com  QIhzh11xal      4627094925.0    Sybilla Magarrell
ttavinor17@google.es    Dc6UqBvM        2118537194.0    Truda   Tavinor
amottershead18@baidu.com        yIOrcb  8965035744.0    Arel    Mottershead
\.


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (email);


--
-- Name: courier courier_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.courier
    ADD CONSTRAINT courier_pkey PRIMARY KEY (email);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (email);


--
-- Name: delivery_fee_per_km delivery_fee_per_km_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.delivery_fee_per_km
    ADD CONSTRAINT delivery_fee_per_km_pkey PRIMARY KEY (id);


--
-- Name: food_category food_category_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.food_category
    ADD CONSTRAINT food_category_pkey PRIMARY KEY (id);


--
-- Name: food_ingredient food_ingredient_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.food_ingredient
    ADD CONSTRAINT food_ingredient_pkey PRIMARY KEY (rname, rbranch, foodname, ingredient);


--
-- Name: food food_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.food
    ADD CONSTRAINT food_pkey PRIMARY KEY (rname, rbranch, foodname);


--
-- Name: ingredient ingredient_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.ingredient
    ADD CONSTRAINT ingredient_pkey PRIMARY KEY (id);


--
-- Name: min_transaction_promo min_transaction_promo_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.min_transaction_promo
    ADD CONSTRAINT min_transaction_promo_pkey PRIMARY KEY (id);


--
-- Name: payment_method payment_method_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.payment_method
    ADD CONSTRAINT payment_method_pkey PRIMARY KEY (id);


--
-- Name: payment_status payment_status_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.payment_status
    ADD CONSTRAINT payment_status_pkey PRIMARY KEY (id);


--
-- Name: promo promo_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.promo
    ADD CONSTRAINT promo_pkey PRIMARY KEY (id);


--
-- Name: restaurant_category restaurant_category_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant_category
    ADD CONSTRAINT restaurant_category_pkey PRIMARY KEY (id);


--
-- Name: restaurant_operating_hours restaurant_operating_hours_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant_operating_hours
    ADD CONSTRAINT restaurant_operating_hours_pkey PRIMARY KEY (name, branch, day);


--
-- Name: restaurant restaurant_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant
    ADD CONSTRAINT restaurant_pkey PRIMARY KEY (rname, rbranch);


--
-- Name: restaurant_promo restaurant_promo_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant_promo
    ADD CONSTRAINT restaurant_promo_pkey PRIMARY KEY (rname, rbranch, pid);


--
-- Name: special_day_promo special_day_promo_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.special_day_promo
    ADD CONSTRAINT special_day_promo_pkey PRIMARY KEY (id);


--
-- Name: transaction_actor transaction_actor_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_actor
    ADD CONSTRAINT transaction_actor_pkey PRIMARY KEY (email);


--
-- Name: transaction_food transaction_food_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_food
    ADD CONSTRAINT transaction_food_pkey PRIMARY KEY (email, datetime, rname, rbranch, foodname);


--
-- Name: transaction_history transaction_history_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_history
    ADD CONSTRAINT transaction_history_pkey PRIMARY KEY (email, datetime, tsid);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (email, datetime);


--
-- Name: transaction_status transaction_status_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_status
    ADD CONSTRAINT transaction_status_pkey PRIMARY KEY (id);


--
-- Name: user_acc user_acc_pkey; Type: CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.user_acc
    ADD CONSTRAINT user_acc_pkey PRIMARY KEY (email);


--
-- Name: transaction_actor trigger_cek_saldo_penarikan_restopay; Type: TRIGGER; Schema: sirest; Owner: db22a003
--

CREATE TRIGGER trigger_cek_saldo_penarikan_restopay BEFORE UPDATE OF restopay ON sirest.transaction_actor FOR EACH ROW EXECUTE PROCEDURE sirest.cek_saldo_penarikan_restopay();


--
-- Name: transaction_status trigger_menambah_restopay; Type: TRIGGER; Schema: sirest; Owner: db22a003
--

CREATE TRIGGER trigger_menambah_restopay AFTER UPDATE OF name ON sirest.transaction_status FOR EACH ROW EXECUTE PROCEDURE sirest.menambah_restopay();


--
-- Name: delivery_fee_per_km triggercheckdeliveryfeeperkm; Type: TRIGGER; Schema: sirest; Owner: db22a003
--

CREATE TRIGGER triggercheckdeliveryfeeperkm BEFORE INSERT OR UPDATE ON sirest.delivery_fee_per_km FOR EACH ROW EXECUTE PROCEDURE sirest.checkdeliveryfeeperkm();


--
-- Name: transaction triggerdeliveryprice; Type: TRIGGER; Schema: sirest; Owner: db22a003
--

CREATE TRIGGER triggerdeliveryprice BEFORE INSERT ON sirest.transaction FOR EACH ROW EXECUTE PROCEDURE sirest.deliveryprice();


--
-- Name: user_acc triggerpendaftaran; Type: TRIGGER; Schema: sirest; Owner: db22a003
--

CREATE TRIGGER triggerpendaftaran BEFORE INSERT ON sirest.user_acc FOR EACH ROW EXECUTE PROCEDURE sirest.pendaftaran();


--
-- Name: admin admin_email_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.admin
    ADD CONSTRAINT admin_email_fkey FOREIGN KEY (email) REFERENCES sirest.user_acc(email);


--
-- Name: courier courier_email_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.courier
    ADD CONSTRAINT courier_email_fkey FOREIGN KEY (email) REFERENCES sirest.transaction_actor(email);


--
-- Name: customer customer_email_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.customer
    ADD CONSTRAINT customer_email_fkey FOREIGN KEY (email) REFERENCES sirest.transaction_actor(email);


--
-- Name: food food_fcategory_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.food
    ADD CONSTRAINT food_fcategory_fkey FOREIGN KEY (fcategory) REFERENCES sirest.food_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: food_ingredient food_ingredient_ingredient_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.food_ingredient
    ADD CONSTRAINT food_ingredient_ingredient_fkey FOREIGN KEY (ingredient) REFERENCES sirest.ingredient(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: food_ingredient food_ingredient_rname_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.food_ingredient
    ADD CONSTRAINT food_ingredient_rname_fkey FOREIGN KEY (rname, rbranch, foodname) REFERENCES sirest.food(rname, rbranch, foodname) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: food food_rname_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.food
    ADD CONSTRAINT food_rname_fkey FOREIGN KEY (rname, rbranch) REFERENCES sirest.restaurant(rname, rbranch) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: min_transaction_promo min_transaction_promo_id_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.min_transaction_promo
    ADD CONSTRAINT min_transaction_promo_id_fkey FOREIGN KEY (id) REFERENCES sirest.promo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurant restaurant_email_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant
    ADD CONSTRAINT restaurant_email_fkey FOREIGN KEY (email) REFERENCES sirest.transaction_actor(email);


--
-- Name: restaurant_operating_hours restaurant_operating_hours_name_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant_operating_hours
    ADD CONSTRAINT restaurant_operating_hours_name_fkey FOREIGN KEY (name, branch) REFERENCES sirest.restaurant(rname, rbranch) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurant_promo restaurant_promo_pid_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant_promo
    ADD CONSTRAINT restaurant_promo_pid_fkey FOREIGN KEY (pid) REFERENCES sirest.promo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: restaurant_promo restaurant_promo_rname_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant_promo
    ADD CONSTRAINT restaurant_promo_rname_fkey FOREIGN KEY (rname, rbranch) REFERENCES sirest.restaurant(rname, rbranch);


--
-- Name: restaurant restaurant_rcategory_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.restaurant
    ADD CONSTRAINT restaurant_rcategory_fkey FOREIGN KEY (rcategory) REFERENCES sirest.restaurant_category(id);


--
-- Name: special_day_promo special_day_promo_id_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.special_day_promo
    ADD CONSTRAINT special_day_promo_id_fkey FOREIGN KEY (id) REFERENCES sirest.promo(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_actor transaction_actor_adminid_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_actor
    ADD CONSTRAINT transaction_actor_adminid_fkey FOREIGN KEY (adminid) REFERENCES sirest.admin(email);


--
-- Name: transaction_actor transaction_actor_email_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_actor
    ADD CONSTRAINT transaction_actor_email_fkey FOREIGN KEY (email) REFERENCES sirest.user_acc(email);


--
-- Name: transaction transaction_courierid_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction
    ADD CONSTRAINT transaction_courierid_fkey FOREIGN KEY (courierid) REFERENCES sirest.courier(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction transaction_dfid_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction
    ADD CONSTRAINT transaction_dfid_fkey FOREIGN KEY (dfid) REFERENCES sirest.delivery_fee_per_km(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction transaction_email_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction
    ADD CONSTRAINT transaction_email_fkey FOREIGN KEY (email) REFERENCES sirest.customer(email) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_food transaction_food_email_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_food
    ADD CONSTRAINT transaction_food_email_fkey FOREIGN KEY (email, datetime) REFERENCES sirest.transaction(email, datetime) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_food transaction_food_rname_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_food
    ADD CONSTRAINT transaction_food_rname_fkey FOREIGN KEY (rname, rbranch, foodname) REFERENCES sirest.food(rname, rbranch, foodname) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_history transaction_history_email_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_history
    ADD CONSTRAINT transaction_history_email_fkey FOREIGN KEY (email, datetime) REFERENCES sirest.transaction(email, datetime) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_history transaction_history_tsid_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction_history
    ADD CONSTRAINT transaction_history_tsid_fkey FOREIGN KEY (tsid) REFERENCES sirest.transaction_status(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction transaction_pmid_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction
    ADD CONSTRAINT transaction_pmid_fkey FOREIGN KEY (pmid) REFERENCES sirest.payment_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction transaction_psid_fkey; Type: FK CONSTRAINT; Schema: sirest; Owner: db22a003
--

ALTER TABLE ONLY sirest.transaction
    ADD CONSTRAINT transaction_psid_fkey FOREIGN KEY (psid) REFERENCES sirest.payment_status(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--