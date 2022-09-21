BEGIN;

CREATE TABLE IF NOT EXISTS public."Employees"
(
    emp_id bigserial NOT NULL,
    first_name character varying(50) NOT NULL CHECK(first_name ~* '^[A-Za-z]+$'),
    surname character varying(50) NOT NULL CHECK(surname ~* '^[A-Za-z]+$'),
    gender "char" NOT NULL CHECK (gender IN ('M','F')),
    address character varying(100) CHECK(address ~* '^[0-9._+%-]+ +[A-Za-z0-9.-]+ +[A-Za-z]+$'),
    email character varying(50) CHECK(email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    depart_id bigint,                   
    role_id bigint,
    salary_id bigint,
    overtime_id bigint,
    PRIMARY KEY (emp_id)
);

CREATE TABLE IF NOT EXISTS public."Department"
(
    depart_id bigserial NOT NULL,
    depart_name character varying(50) NOT NULL CHECK(depart_name ~* '^[A-Za-z]+$'),
    depart_city character varying(50) NOT NULL CHECK(depart_city ~* '^[A-Za-z]+$'),
    PRIMARY KEY (depart_id)
);

CREATE TABLE IF NOT EXISTS public."Roles"
(
    role_id bigserial NOT NULL,
    role character varying(50) NOT NULL,
    PRIMARY KEY (role_id)
);

CREATE TABLE IF NOT EXISTS public."Salaries"
(
    salary_id bigserial NOT NULL,
    salary_pa numeric(15, 2) NOT NULL,
    PRIMARY KEY (salary_id)
);

CREATE TABLE IF NOT EXISTS public."OvertimeHours"
(
    overtime_id bigserial NOT NULL,
    overtime_hours numeric(15, 2),
    PRIMARY KEY (overtime_id)
);

ALTER TABLE IF EXISTS public."Employees"
    ADD FOREIGN KEY (depart_id)
    REFERENCES public."Department" (depart_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public."Employees"
    ADD FOREIGN KEY (role_id)
    REFERENCES public."Roles" (role_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public."Employees"
    ADD FOREIGN KEY (salary_id)
    REFERENCES public."Salaries" (salary_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

ALTER TABLE IF EXISTS public."Employees"
    ADD FOREIGN KEY (overtime_id)
    REFERENCES public."OvertimeHours" (overtime_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;

-----------------------------------------------
INSERT INTO public."Department"(depart_name,depart_city)
VALUES ('Marketing','Lazytown'),
('Sales','Hypertown');
SELECT * FROM public."Department";
-----------------------------------------------
INSERT INTO public."Roles"(role)
VALUES ('sell some items'),
('see what people like');
SELECT * FROM public."Roles";
-----------------------------------------------
INSERT INTO public."Salaries"(salary_pa)
VALUES (12345.66),
(12000000.887);
SELECT * FROM public."Salaries";
-----------------------------------------------
INSERT INTO public."OvertimeHours"(overtime_hours)
VALUES (65.66),(12.66);
SELECT * FROM public."OvertimeHours";
-----------------------------------------------
INSERT INTO public."Employees"(first_name,surname,gender,address,email,depart_id,role_id,salary_id,overtime_id)
VALUES ('james','smith','M','42 Benny St','jamess54@gmail.com',1,1,1,1),
('sarah','ann','F','242 Sunflower St','sarah43ann@gmail.com',2,2,2,2);
SELECT * FROM public."Employees";
-----------------------------------------------

SELECT depart_name,role,salary_pa,overtime_hours
FROM public."Employees"
LEFT JOIN public."Department" ON public."Employees".depart_id = public."Department".depart_id
LEFT JOIN public."OvertimeHours" ON public."Employees".overtime_id = public."OvertimeHours".overtime_id
LEFT JOIN public."Roles" ON public."Employees".role_id = public."Roles".role_id
LEFT JOIN public."Salaries" ON public."Employees".salary_id = public."Salaries".salary_id;