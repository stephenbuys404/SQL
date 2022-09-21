BEGIN;

CREATE TABLE IF NOT EXISTS public.my_contacts
(
    contact_id bigserial NOT NULL,
    last_name character varying(50) NOT NULL CHECK(last_name ~* '^[A-Za-z]+$'),
    first_name character varying(50) NOT NULL CHECK(first_name ~* '^[A-Za-z]+$'),
    phone character varying(10) CHECK(phone ~ '^[0-9]{10}$'),
    email character varying CHECK(email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    gender "char" CHECK (gender IN ('M','F')),
    birthday date NOT NULL,
    prof_id bigint NOT NULL,
    zip_code bigint NOT NULL CHECK (zip_code < 9999 AND zip_code >999),
    status_id bigint NOT NULL,
    PRIMARY KEY (contact_id)
);

CREATE TABLE IF NOT EXISTS public.profession
(
    prof_id bigserial NOT NULL,
    profession character varying(50) NOT NULL CHECK(profession ~* '^[A-Za-z]+$'),
    PRIMARY KEY (prof_id)
);

CREATE TABLE IF NOT EXISTS public.zip_code
(
    zip_code bigint NOT NULL CHECK (zip_code < 9999 AND zip_code >999),
    city character varying(50) NOT NULL CHECK(city ~* '^[A-Za-z]+$'),
    province character varying(50) NOT NULL CHECK(province ~* '^[A-Za-z]+$'),
    PRIMARY KEY (zip_code)
);

CREATE TABLE IF NOT EXISTS public.status
(
    status_id bigserial NOT NULL,
    status character varying(50) NOT NULL CHECK(status ~* '^[A-Za-z]+$'),
    PRIMARY KEY (status_id)
);

CREATE TABLE IF NOT EXISTS public.contact_interest
(
    contact_id bigint NOT NULL,
    interest_id bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS public.contact_seeking
(
    contact_id bigint NOT NULL,
    seeking_id bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS public.interests
(
    interest_id bigserial NOT NULL,
    interest character varying(50) NOT NULL,
    PRIMARY KEY (interest_id)
);

CREATE TABLE IF NOT EXISTS public.seeking
(
    seeking_id bigserial NOT NULL,
    seeking character varying(50) NOT NULL,
    PRIMARY KEY (seeking_id)
);

ALTER TABLE IF EXISTS public.my_contacts
    ADD FOREIGN KEY (prof_id)
    REFERENCES public.profession (prof_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.my_contacts
    ADD FOREIGN KEY (zip_code)
    REFERENCES public.zip_code (zip_code) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.my_contacts
    ADD FOREIGN KEY (status_id)
    REFERENCES public.status (status_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.contact_interest
    ADD FOREIGN KEY (contact_id)
    REFERENCES public.my_contacts (contact_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.contact_interest
    ADD FOREIGN KEY (interest_id)
    REFERENCES public.interests (interest_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.contact_seeking
    ADD FOREIGN KEY (contact_id)
    REFERENCES public.my_contacts (contact_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public.contact_seeking
    ADD FOREIGN KEY (seeking_id)
    REFERENCES public.seeking (seeking_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;

--------------------------------------
INSERT INTO public.profession(profession)
VALUES ('Teacher'),('Lawyer'),('Driver'),('Scientist'),('Racer'),('Docter');
SELECT * FROM public.profession;

INSERT INTO public.zip_code(zip_code,city,province)
VALUES (1643,'downtownA','stateA'),
(1644,'downtownB','stateB'),
(1645,'downtownC','stateC'),
(1646,'downtownD','stateD'),
(1647,'downtownE','stateE');
SELECT * FROM public.zip_code;

INSERT INTO public.status(status)
VALUES ('Single'),('Divorced'),('Maried'),('Complicated');
SELECT * FROM public.status;

INSERT INTO public.my_contacts(last_name,first_name,phone,email,gender,birthday,prof_id,zip_code,status_id)
VALUES ('surnameA','nameA','0231156332','A@gmail.com','M','2022-7-22',1,1644,1),
('surnameB','nameB','0231156332','B@gmail.com','F','2022-7-22',2,1645,2),
('surnameC','nameC','0231156332','C@gmail.com','M','2022-7-22',3,1646,3),
('surnameD','nameD','0231156332','D@gmail.com','M','2022-7-22',4,1647,4);
SELECT * FROM public.my_contacts;

INSERT INTO public.interests(interest)
VALUES ('Writing'),('Volunteering'),('Events'),('Learning'),('Traveling'),('Sports');
SELECT * FROM public.interests;

INSERT INTO public.contact_interest(contact_id,interest_id)
VALUES (1,1),(1,2),(1,3),
(2,4),(2,5),(2,6),
(3,1),(3,3),(3,5),
(4,3),(4,2),(4,1);
SELECT * FROM public.contact_interest;

INSERT INTO public.seeking(seeking)
VALUES ('Personality'),('Available'),('Unavailable');
SELECT * FROM public.seeking;

INSERT INTO public.contact_seeking(contact_id,seeking_id)
VALUES (1,1),(1,2),
(2,3),(2,2),
(3,1),(3,2),
(4,2),(4,3);
SELECT * FROM public.contact_seeking;

-----------------------------------------
SELECT
my_contacts.last_name,
my_contacts.first_name,
my_contacts.phone,
my_contacts.email,
my_contacts.gender,
my_contacts.birthday,
profession.profession,
zip_code.city,
zip_code.province,
status.status,
seeking.seeking,
interests.interest
FROM my_contacts
-----------------------------------------
INNER JOIN profession
ON my_contacts.prof_id = profession.prof_id
-----------------------------------------
INNER JOIN zip_code
ON my_contacts.zip_code = zip_code.zip_code
-----------------------------------------
INNER JOIN status
ON my_contacts.status_id = status.status_id
-----------------------------------------
INNER JOIN contact_seeking
ON my_contacts.contact_id = contact_seeking.contact_id

INNER JOIN seeking
ON contact_seeking.seeking_id = seeking.seeking_id
-----------------------------------------
INNER JOIN contact_interest
ON my_contacts.contact_id = contact_interest.contact_id

INNER JOIN interests
ON contact_interest.interest_id = interests.interest_id;
-----------------------------------------